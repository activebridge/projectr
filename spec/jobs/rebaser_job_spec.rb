require 'rails_helper'

RSpec.describe RebaserJob, type: :job do
  let(:user) { create(:user) }
  let(:repo) { create(:repo, user: user) }
  let(:rebase) { create(:rebase, repo: repo.name) }
  let(:admin_repo) { build(:admin_repo, permissions: double(admin: true)) }
  let(:git_repo) { build(:git_repo) }
  let(:collaborator) { double(id: 258) }
  let(:webhook) { build(:webhook) }
  let(:deploy_key) { build(:deploy_key) }
  let(:status) { { 'statuses' => [{ 'state' => 'pending' }] } }
  let(:pull) { { 'state' => 'open' } }
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
      status: status,
      pull: pull
    )
  end
  let(:pull_request) do
    {
      'id' => rebase.github_id,
      'base' => { 'ref' => 'base' },
      'head' => { 'ref' => 'head', 'sha' => 'sha' },
      'state' => 'open',
      'number' => 2
    }
  end
  let(:payload) do
    {
      'repository' => { 'full_name' => repo.name },
      'pull_request' => pull_request
    }
  end

  before do
    allow(RefresherJob).to receive(:new).and_return(double(perform: []))
    allow(Octokit::Client).to receive(:new).and_return(github)
  end

  context 'when conflict' do
    let(:status) { { 'statuses' => [{ 'state' => 'error' }] } }

    before do
      allow_any_instance_of(Github).to receive(:rebase).and_return('conflict')
      expect(described_class.perform_now(payload))
    end

    it { expect(Rebase.find_by(repo: repo.name).status).to eq('error') }
  end

  context 'when fail' do
    let(:status) { { 'statuses' => [{ 'state' => 'failure' }] } }

    before do
      allow_any_instance_of(Github).to receive(:rebase).and_return('fail')
      allow(PusherJob).to receive(:new).and_return(double(perform: []))
      expect(described_class.perform_now(payload))
    end

    it { expect(Rebase.find_by(repo: repo.name).status).to eq('failure') }
  end

  context 'when success' do
    let(:status) { { 'statuses' => [{ 'state' => 'success' }] } }

    before do
      allow_any_instance_of(Github).to receive(:rebase).and_return(nil)
      expect(described_class.perform_now(payload))
    end

    it { expect(Rebase.find_by(repo: repo.name).status).to eq('success') }
  end
end
