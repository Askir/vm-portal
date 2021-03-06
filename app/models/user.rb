# frozen_string_literal: true

require 'sshkey'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  before_create :set_user_id

  after_save :update_repository

  after_initialize :set_default_role, if: :new_record?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable, omniauth_providers: %i[hpi]
  enum role: %i[user employee admin]

  has_many :users_assigned_to_requests
  has_many :requests, through: :users_assigned_to_requests
  has_many :servers
  has_many :notifications
  has_and_belongs_to_many :request_responsibilities, class_name: 'Request', join_table: 'requests_responsible_users'
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :valid_ssh_key

  has_and_belongs_to_many :responsible_projects,
                          class_name: 'Project',
                          join_table: :responsible_users,
                          foreign_key: :project_id,
                          association_foreign_key: :user_id

  # slack integration
  has_many :slack_auth_requests, dependent: :destroy
  has_many :slack_hooks, dependent: :destroy
  def notify_slack(message)
    slack_hooks.each do |hook|
      hook.post_message message
    end
  end

  def self.search(term, role)
    if term
      users = where('first_name LIKE ? or last_name LIKE ?', "%#{term}%", "%#{term}%")
      users = users.where(role: role) if role && role != ''
      users.order(last_name: :asc)
    else
      order(last_name: :asc)
    end
  end

  # notifications
  def notify(title, message, link = '', type: :default)
    # notifications are ordered by descending created_at order (see `models/notification.rb`)
    # notifications with the newest ("largest") timestamps are first
    last_notification = notifications.first
    # Set the `created_at` attribute, so that it can be compared by the `duplicate_of`
    notification = Notification.new title: title, message: message, notification_type: type, user_id: id, read: false, link: link, created_at: DateTime.current

    if notification.duplicate_of last_notification
      last_notification.update(count: last_notification.count + 1)
    else
      notify_slack("*#{title}*\n#{message}\n#{link}")
      NotificationMailer.with(user: self, title: '[HART] ' + title.to_s, message: (message + link).to_s).notify_email.deliver_now if email_notifications
      notification.save
      # saving might fail, there is however no good way to handle this error.
      # We cannot log the error, because when using the HartFormatter, logging errors creates new notifications,
      # these might also fail to save, creating an endless recursion.
    end
  end

  after_initialize :set_default_role, if: :new_record?

  def ssh_key?
    ssh_key&.length&.positive?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def human_readable_identifier
    email.split(/@/).first.capitalize.gsub(/[-.][a-z]/, &:upcase) # Capitalize the first letter and upcase every letter that follows a . or -
  end

  def valid_ssh_key
    # https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
    errors.add(:ssh_key, :invalid, message: "must be a valid SSH-Key") unless valid_ssh_key?
  end

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.role = :user
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
    end
  end

  def self.from_mail_identifier(mail_id)
    all.each do |user|
      return user if user.human_readable_identifier.casecmp(mail_id).zero?
    end
    nil
  end

  def vms
    VSphere::VirtualMachine.user_vms self
  end

  def employee_or_admin?
    employee? || admin?
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def set_user_id
    # Lock this method to prevent race conditions when two users are created at the same time
    User.with_advisory_lock('user_id_lock') do
      self.user_id = if User.maximum(:user_id)
                       (User.maximum(:user_id) + 1) || Rails.configuration.start_user_id
                     else
                       Rails.configuration.start_user_id
                     end
    end
  end

  def update_repository
    GitHelper.open_git_repository(for_write: true) do |git_writer|
      git_writer.write_file(Puppetscript.init_file_name, generate_puppet_init_script)
      message = if git_writer.added?
                  'Create init.pp'
                else
                  "Add #{name}"
                end
      git_writer.save(message)
    end
  rescue Git::GitExecuteError => e
    logger.error(e)
  end

  def generate_puppet_init_script
    Puppetscript.init_script(User.unscoped.order(user_id: :asc))
  end

  def valid_ssh_key?
    !ssh_key? || SSHKey.valid_ssh_public_key?(ssh_key)
  end
end
