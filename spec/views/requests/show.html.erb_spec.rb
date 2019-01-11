# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/show', type: :view do
  let(:current_user) { FactoryBot.create :employee }

  let(:request) do
    Request.create!(
      name: 'MyVM',
      cpu_cores: 2,
      ram_mb: 1000,
      storage_mb: 2000,
      operating_system: 'MyOS',
      port: '4000',
      application_name: 'MyName',
      comment: 'Comment',
      status: 'pending',
      user: FactoryBot.create :employee
    )
  end

  before do
    allow(view).to receive(:current_user).and_return(current_user)
    assign(:request, request)
    render
  end

  it 'renders attributes in <p>' do
    expect(rendered).to match(/MyVM/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/1000/)
    expect(rendered).to match(/2000/)
    expect(rendered).to match(/4000/)
    expect(rendered).to match(/MyName/)
    expect(rendered).to match(/Comment/)
    expect(rendered).to match(/pending/)
  end

  context 'when the current user is an employee' do
    let(:current_user) { FactoryBot.create :employee }

    it 'does not show the accept part of the page' do
      expect(rendered).not_to have_selector 'div#acceptAndReject'
    end
  end

  context 'when the current user is an admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'does show the accept and reject part' do
      expect(rendered).to have_selector 'div#acceptAndReject'
    end
  end
end
