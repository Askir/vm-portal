# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'can be created using the User factory' do
    user = FactoryBot.create(:user)
    expect(user.email).to include '@'
  end

  it 'can be a user' do
    user = FactoryBot.create(:user, role: :user)
    expect(user).to be_user
    expect(user).not_to be_employee
    expect(user).not_to be_admin
  end

  it 'can be a employee' do
    user = FactoryBot.create(:user, role: :employee)
    expect(user).not_to be_user
    expect(user).to be_employee
    expect(user).not_to be_admin
  end

  it 'can be an admin' do
    user = FactoryBot.create(:user, role: :admin)
    expect(user).not_to be_user
    expect(user).not_to be_employee
    expect(user).to be_admin
  end

  it 'defaults to user' do
    user = FactoryBot.create :user
    expect(user).to be_truthy
  end

  describe 'creating a user with openid connect' do
    let(:auth) { double }
    let(:info) { double }
    let(:user) { User.from_omniauth(auth) }
    let(:mail) { Faker::Internet.safe_email }

    before do
      allow(auth).to receive(:info).and_return(info)
      allow(auth).to receive(:provider).and_return('testprovider')
      allow(auth).to receive(:uid).and_return(1)

      allow(info).to receive(:first_name).and_return('First')
      allow(info).to receive(:last_name).and_return('Last')
      allow(info).to receive(:email).and_return(mail)
    end

    context 'when the user does not exist' do
      before do
        @git_stub = create_git_stub
      end

      after do
        @git_stub.delete
      end

      it 'creates a new user' do
        expect { user }.to change(User, :count).by(1)
      end

      it 'persists the new user' do
        expect(user).to be_persisted
      end

      it 'sets the users first name' do
        expect(user.first_name).to eq('First')
      end

      it 'sets the users last name' do
        expect(user.last_name).to eq('Last')
      end

      it 'sets the users email' do
        expect(user.email).to eq(mail)
      end

      it 'adds the users to puppet_script init' do
        allow(@git_stub.status).to receive(:changed).and_return(['init.pp'])
        allow(@git_stub.status).to receive(:added).and_return([])
        allow_any_instance_of(User).to receive(:update_repository).and_call_original

        user
        expect(@git_stub.git).to have_received(:commit_all).with('Add First Last')
      end
    end

    context 'when the user already exists' do
      let!(:existing_user) { FactoryBot.create :user, uid: 1, provider: 'testprovider', email: 'oldemail@mail.com' }

      it 'does not create a new user' do
        expect { user }.to change(User, :count).by(0)
      end

      it 'returns the existing user' do
        expect(user.id).to eq(existing_user.id)
      end
    end
  end

  context 'setting the user id' do
    let!(:user) { FactoryBot.create :user }

    it 'larger than or equal to 4000' do
      expect(user.user_id).to be >= 4000
    end

    it 'increments the user id when more users are created' do
      user2 = FactoryBot.create :user
      expect(user2.user_id).to be > user.user_id
    end
  end

  describe 'notifying the user' do
    let(:user) { FactoryBot.create :user }

    def notify_user
      user.notify 'my notification', 'some message', 'https://www.google.com/'
    end

    it 'creates a notification object' do
      expect { notify_user }.to change(Notification, :count).by(1)
    end

    it 'notifies slack' do
      allow(user).to receive(:notify_slack)
      notify_user
      expect(user).to have_received(:notify_slack)
    end

    it 'does not create multiple duplicate notifications' do
      3.times { notify_user }
      expect(user.notifications.size).to eq(1)
    end

    it 'sets the count of duplicate notifications correctly' do
      4.times { notify_user }
      expect(user.notifications.first.count).to eq(4)
    end

    it 'does not notify slack for duplicate notifiations' do
      allow(user).to receive(:notify_slack)
      3.times { notify_user }
      expect(user).to have_received(:notify_slack).once
    end

    it 'does create notifications if the duplicates are one minute apart' do
      notify_user
      new_time = Time.now + 61 # seconds
      allow(Time).to receive(:now).and_return new_time
      expect { notify_user }.to change(Notification, :count).by(1)
    end
  end
end
