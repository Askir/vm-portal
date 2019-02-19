# frozen_string_literal: true

class AppSetting < ApplicationRecord
  validates_inclusion_of :singleton_guard, in: [0]
  validates_format_of :github_user_email, with: Devise.email_regexp, allow_blank: true
  validates :email_notification_smtp_port, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 65_535 }, allow_nil: true
  validates :vm_archivation_timeout, numericality: { greater_than_or_equal_to: 0 }

  after_update do |setting|
    Rails.configuration.action_mailer.smtp_settings = {
      address: setting.email_notification_smtp_address,
      port: setting.email_notification_smtp_port,
      domain: setting.email_notification_smtp_domain,
      user_name: setting.email_notification_smtp_user,
      password: setting.email_notification_smtp_password,
      authentication: :plain
    }
  end

  def self.instance
    first_or_create!(singleton_guard: 0,
                     vm_archivation_timeout: 3) # in days
  end
end
