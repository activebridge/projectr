require 'rails_helper'

RSpec.describe RefresherJob, type: :job do
  let(:user) { create(:user) }
  let(:repo) { create(:repo, user: user) }
  let(:rebase) { create(:rebase, repo: repo.name) }
  let(:admin_repo) { build(:admin_repo, permissions: double(admin: true)) }
  let(:git_repo) { build(:git_repo) }
  let(:collaborator) { double(id: 258) }
  let(:webhook) { build(:webhook) }
  let(:deploy_key) { build(:deploy_key) }
  let(:status) { { 'statuses' => [{ 'context' => 'ProjectR', 'state' => 'success' }] } }
  let(:pull_request) { build(:pull_request) }
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
      pulls: [pull_request],
      pull: pull_request
    )
  end

  before do
    allow_any_instance_of(Github).to receive(:rebase).and_return(nil)
    allow(Octokit::Client).to receive(:new).and_return(github)
    expect(described_class.perform_now(repo.name, rebase.base))
  end

  it { expect(Rebase.find_by(github_id: pull_request['id']).status).to eq('success') }
end
