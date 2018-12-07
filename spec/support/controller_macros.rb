# frozen_string_literal: true

module ControllerMacros
  def login_admin
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in FactoryBot.create(:user, role: :admin)
    end
  end

  def login_wimi
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in FactoryBot.create(:user, role: :wimi)
    end
  end

  def login_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in FactoryBot.create(:user)
    end
  end
end
