# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/show', type: :view do
  before do
    @user = FactoryBot.create(:user)
    @request = assign(:request, Request.create!(
                                  name: 'MyVM',
                                  cpu_cores: 2,
                                  ram_mb: 1000,
                                  storage_mb: 2000,
                                  operating_system: 'MyOS',
                                  comment: 'Comment',
                                  status: 'pending',
                                  user_ids: [@user.id],
                                  sudo_user_ids: [@user.id]
                                ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/MyVM/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/1000/)
    expect(rendered).to match(/2000/)
    expect(rendered).to match(/Comment/)
    expect(rendered).to match(/pending/)
    expect(rendered).to match(@user.email)
  end
end
