require 'rails_helper'

RSpec.describe Rebase, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to(:repository)
        .class_name('Repo')
        .with_foreign_key(:repo)
        .with_primary_key(:name)
    end
  end

  describe 'validates' do
    it { is_expected.to validate_presence_of(:base) }
    it { is_expected.to validate_presence_of(:head) }
    it { is_expected.to validate_presence_of(:sha) }
  end

  describe 'delegate' do
    it { is_expected.to delegate_method(:user).to(:repository) }
    it { is_expected.to delegate_method(:name).to(:repository).with_prefix }
  end

  describe '#update_with_payload' do
    let(:instance) { described_class.new }
    let(:params) do
      {
        repo: 'repo', base: 'base',
        head: 'head', sha: 'sha', state: 'open'
      }
    end
    let(:pull_request) do
      {
        'base' => { 'ref' => params[:base] },
        'head' => { 'ref' => params[:head], 'sha' => params[:sha] },
        'state' => params[:state],
        'number' => 2
      }
    end
    let(:payload) do
      {
        'repository' => { 'full_name' => params[:repo] },
        'pull_request' => pull_request
      }
    end
    let(:status) { { status: 'success' } }
    let(:attributes) { { payload: payload, status: status } }

    subject { -> { instance.update_with_payload(attributes) } }

    it { is_expected.to change(instance, :repo) }
    it { is_expected.to change(instance, :base) }
    it { is_expected.to change(instance, :head) }
    it { is_expected.to change(instance, :sha) }
    it { is_expected.to change(instance, :state) }
    it { is_expected.to change(instance, :number) }
    it { is_expected.to change(instance, :status) }
  end
end
