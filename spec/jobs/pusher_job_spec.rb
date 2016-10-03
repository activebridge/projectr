require 'rails_helper'

RSpec.describe PusherJob, type: :job do
  let(:user) { create(:user) }
  let(:repo) { create(:repo, user: user) }
  let(:rebase) { create(:rebase, repo: repo.name) }
  let(:admin_repo) { build(:admin_repo, permissions: double(admin: true)) }
  let(:git_repo) { build(:git_repo) }
  let(:collaborator) { double(id: 258) }
  let(:webhook) { build(:webhook) }
  let(:deploy_key) { build(:deploy_key) }
  let(:status) { { 'statuses' => [{ 'state' => 'pending' }] } }
  let(:github) do
    double(
      repos: [admin_repo],
      collaborators: [collaborator],
      repo: git_repo,
      hooks: [webhook],
      create_hook: webhook,
      deploy_keys: [deploy_key],
      add_deploy_key: deploy_key,
      create_status: status,
      status: status
    )
  end

  before do
    allow(RefresherJob).to receive(:new).and_return(double(perform: []))
    allow(Octokit::Client).to receive(:new).and_return(github)
  end

  context 'when push success' do
    let(:sha) { FFaker::IdentificationMX.rfc }
    let(:status) { { 'statuses' => [{ 'state' => 'success' }] } }

    before do
      allow_any_instance_of(Github).to receive(:push).and_return(sha)
      expect(described_class.perform_now(rebase))
    end

    it { expect(rebase.sha).to eq(sha) }
    it { expect(rebase.pushed).to eq(true) }
    it { expect(rebase.status).to eq('success') }
  end

  context 'when push failure' do
    let(:status) { { 'statuses' => [{ 'state' => 'failure' }] } }

    before do
      allow_any_instance_of(Github).to receive(:push).and_return(nil)
      expect(described_class.perform_now(rebase))
    end

    it { expect(rebase.status).to eq('failure') }
  end
end
