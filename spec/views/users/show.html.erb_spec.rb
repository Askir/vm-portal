# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show.html.erb', type: :view do
  let(:project) { FactoryBot.create :project }
  let(:user) { FactoryBot.create :employee, responsible_projects: [project] }
  let(:current_user) { FactoryBot.create :user, responsible_projects: [project] }

  before do
    allow(view).to receive(:current_user).and_return(current_user)
    assign(:user, user)
    project
    render
  end

  it 'shows the users name' do
    expect(rendered).to include user.name
  end

  it 'shows the users email' do
    expect(rendered).to include user.email
  end

  it 'shows the users role' do
    expect(rendered).to include user.role
  end

  it 'shows the responsible projects name' do
    expect(rendered).to include project.name
  end

  it 'shows other users of the responsible projects' do
    expect(rendered).to include current_user.name
  end

  context 'when the requested user is the current user' do
    before do
      allow(view).to receive(:current_user).and_return(user)
      render
    end

    it 'shows an edit button' do
      expect(rendered).to have_link(id: 'editUserButton', href: edit_user_path(user))
    end

    context 'when the user has a ssh key' do
      it 'shows the ssh key' do
        expect(rendered).to include user.ssh_key
      end
    end

    context 'when the user has no ssh key' do
      let(:user) { FactoryBot.create :user, ssh_key: '' }

      it 'shows a no ssh-key text' do
        expect(rendered).to include 'No SSH-Key'
      end
    end
  end

  context 'when the current user is an admin but not the requested user' do
    let(:admin) { FactoryBot.create :user }

    before do
      allow(view).to receive(:current_user).and_return(admin)
      render
    end

    it 'does not show the ssh-key' do
      expect(rendered).not_to include user.ssh_key
    end

    it 'does not show the edit-button' do
      expect(rendered).not_to have_link(id: 'editUserButton', href: edit_user_path(user))
    end
  end
end
