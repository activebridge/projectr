require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:repos).dependent(:delete_all) }
    it { is_expected.to have_many(:rebases).through(:repos) }
  end

  describe '#update_with_github' do
    let(:instance) { described_class.new }
    let(:info) do
      double(
        name: 'Name', login: 'Login',
        email: 'email@example.com', avatar_url: 'url'
      )
    end
    let(:token) { 'token' }

    subject { -> { instance.update_with_github(info, token) } }

    it { is_expected.to change(instance, :name) }
    it { is_expected.to change(instance, :username) }
    it { is_expected.to change(instance, :email) }
    it { is_expected.to change(instance, :avatar) }
    it { is_expected.to change(instance, :token) }
  end

  describe '#github' do
    let(:attributes) { { access_token: 'token', per_page: 100 } }
    let(:token) { 'token' }

    subject { described_class.new(token: token).github }

    it { is_expected.to be_instance_of(Octokit::Client) }

    context 'creates new instance of client' do
      it { expect(Octokit::Client).to receive(:new).with(attributes) }

      after { subject }
    end
  end
end
