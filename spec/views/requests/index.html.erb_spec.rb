# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/index', type: :view do
  let(:requests) do
    [
      Request.create!(
        name: 'myvm',
        cpu_cores: 3,
        ram_gb: 1,
        storage_gb: 2,
        operating_system: 'MyOS',
        port: '4000',
        application_name: 'MyName',
        description: 'Description',
        comment: 'Comment',
        status: 'pending',
        user: FactoryBot.create(:employee),
        responsible_users: [FactoryBot.create(:user)]
      ),
      Request.create!(
        name: 'myvm1',
        cpu_cores: 3,
        ram_gb: 1,
        storage_gb: 2,
        operating_system: 'MyOS',
        port: '4000',
        application_name: 'MyName',
        description: 'Description',
        comment: 'Comment',
        status: 'pending',
        user: FactoryBot.create(:employee),
        responsible_users: [FactoryBot.create(:user)]
      )
    ]
  end

  before do
    assign(:pending_requests, requests)
    assign(:resolved_requests, requests)
    render
  end

  it 'renders a list of all requests' do
    assert_select 'tr>td', text: 'myvm'.to_s, count: 2
    assert_select 'tr>td', text: 'myvm1'.to_s, count: 2
    assert_select 'tr>td', text: 3.to_s, count: 4
    assert_select 'tr>td', text: '1 GB', count: 4
    assert_select 'tr>td', text: '2 GB', count: 4
    assert_select 'tr>td', text: 'MyOS'.to_s, count: 4
    assert_select 'tr>td', text: 4000.to_s, count: 4
    assert_select 'tr>td', text: 'MyName'.to_s, count: 4
    assert_select 'tr>td', text: 'Comment'.to_s, count: 4
  end

  it 'has a link to edit the request status' do
    expect(rendered).to have_link(href: request_path(requests[0]))
    expect(rendered).to have_link(href: request_path(requests[1]))
  end
end
