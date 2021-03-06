# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'End to End testing', type: :feature do
  let(:host) do
    v_sphere_host_mock('someHost')
  end

  before do
    @user = FactoryBot.create :user
    @employee = FactoryBot.create :employee
    @admin = FactoryBot.create :admin
    @requestname = 'capybara-test-vm'
    @project = FactoryBot.create :project
    allow(VSphere::Host).to receive(:all).and_return [host]
  end

  describe 'GET "/" - Landing Page'
  it 'has a o-auth log-in button' do
    visit '/'
    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_link('Sign in with HPI OpenID Connect')
  end

  describe 'Request Process'
  it 'is possible to request a new VM' do
    sign_in @employee
    visit vms_path
    find("a[href='#{new_request_path}']").click
    expect(page).to have_current_path(new_request_path)
    fill_in('request[name]', with: @requestname)
    fill_in('request[cpu_cores]', with: 4)
    fill_in('request[ram_gb]', with: 8)
    fill_in('request[storage_gb]', with: 126)
    select(@employee.human_readable_identifier, from: 'request_responsible_user_ids')
    select(@employee.human_readable_identifier, from: 'request_sudo_user_ids')
    select(@user.human_readable_identifier, from: 'request_user_ids')
    select(I18n.t('blank_text'), from: 'operating_system')
    select(@project.name, from: 'request_project_id')
    fill_in('Description', with: 'test')
    click_on 'Create Request'
    expect(page).to have_css '.alert-success'
    expect(page).to have_current_path('/vms/requests')
    click_on @requestname
    expect(page.body).to have_text('Request Information')
  end
  
  it 'is possible to accept a VM request' do
    sign_in @admin
    visit vms_path
    find("a[href='#{new_request_path}']").click
    fill_in('request[name]', with: @requestname)
    fill_in('request[cpu_cores]', with: 4)
    fill_in('request[ram_gb]', with: 8)
    fill_in('request[storage_gb]', with: 126)
    select(@admin.human_readable_identifier, from: 'request_responsible_user_ids')
    select(@admin.human_readable_identifier, from: 'request_sudo_user_ids')
    select(@user.human_readable_identifier, from: 'request_user_ids')
    select(@project.name, from: 'request_project_id')
    select(I18n.t('blank_text'), from: 'operating_system')
    fill_in('Description', with: 'test')
    click_on 'Create Request'
    click_on @requestname
    expect(page).to have_button('acceptButton')
    expect(page).to have_button('rejectButton')

    # click_on 'acceptButton'
    # expect(page).to have_text('Request was successfully updated and the vm was successfully created.')
    # expect(page).to have_text('Editing configuration of VM')
    # fill_in('virtual_machine_config_ip', :with => '123.0.0.23')
    # fill_in('virtual_machine_config_dns', :with => 'www.example.com')
    # click_on 'Update Configuration'
    # expect(page).to have_text('Successfully updated configuration')
    # expect(current_path).to eq('/vms/requests')
    # click_on @requestname
    # expect(page).to have_text('accepted')
    # visit "/vms/#{@requestname}"
    # expect(page).to have_text('offline')
  end

  it 'is possible to turn on a VM' do
    sign_in @admin
    visit vms_path
    find("a[href='#{new_request_path}']").click
    fill_in('request[name]', with: @requestname)
    fill_in('request[description]', with: 'test')
    select(@project.name, from: 'request_project_id')
    fill_in('request[cpu_cores]', with: 4)
    fill_in('request[ram_gb]', with: 8)
    fill_in('request[storage_gb]', with: 126)
    select(@admin.human_readable_identifier, from: 'request_responsible_user_ids')
    select(@admin.human_readable_identifier, from: 'request_sudo_user_ids')
    select(@user.human_readable_identifier, from: 'request_user_ids')
    select(I18n.t('blank_text'), from: 'request[operating_system]')
    click_on 'Create Request'
    click_on @requestname
    click_on 'acceptButton'
    fill_in('vm_info[ip]', with: '123.0.0.23')
    fill_in('vm_info[dns]', with: 'www.example.com')
    click_on 'Update'
    click_on @requestname
    visit "/vms/vm/#{@requestname}"
    expect(page).to have_text('offline')
    click_on 'Power On'
    expect(page).to have_text('online')
  end
end
