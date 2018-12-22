# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:admin) { FactoryBot.create :admin }
  let(:employee) { FactoryBot.create :employee }

  context 'when the current_user is an admin' do
    before do
      user
      employee
      sign_in admin
      visit users_path
    end

    context 'looking at a normal user' do
      it 'shows that the role is user' do
        expect(page.find(id: "btn-user-#{user.id}")[:class]).to include 'active'
        expect(page.find(id: "btn-employee-#{user.id}")[:class]).not_to include 'active'
        expect(page.find(id: "btn-admin-#{user.id}")[:class]).not_to include 'active'
      end
    end

    context 'looking at an employee' do
      it 'shows that the role is employee' do
        expect(page.find(id: "btn-user-#{employee.id}")[:class]).not_to include 'active'
        expect(page.find(id: "btn-employee-#{employee.id}")[:class]).to include 'active'
        expect(page.find(id: "btn-admin-#{employee.id}")[:class]).not_to include 'active'
      end
    end

    context 'looking at a admin' do
      it 'shows that the role is admin' do
        expect(page.find(id: "btn-user-#{admin.id}")[:class]).not_to include 'active'
        expect(page.find(id: "btn-employee-#{admin.id}")[:class]).not_to include 'active'
        expect(page.find(id: "btn-admin-#{admin.id}")[:class]).to include 'active'
      end
    end
  end
end
