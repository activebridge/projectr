require 'rails_helper'

RSpec.describe StateUpdaterWorker, type: :job do
  let(:user) { create(:user) }
  let(:repo) { create(:repo, user: user) }
  let(:admin_repo) { build(:admin_repo, permissions: double(admin: true)) }
  let(:git_repo) { build(:git_repo) }
  let(:collaborator) { double(id: 258) }
  let(:webhook) { build(:webhook) }
  let(:deploy_key) { build(:deploy_key) }
  let(:status) { { statuses: [{ context: 'ProjectR', state: 'success' }] } }
  let(:pull_request) { build(:pull_request, state: 'closed') }
  let(:updated_pull) { pull_request.update('state' => 'closed') }
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
  let(:payload) do
    {
      'repository' => { 'full_name' => repo.name },
      'pull_request' => pull_request
    }
  end

  before do
    allow_any_instance_of(Github).to receive(:rebase).and_return(nil)
    allow(StateUpdaterWorker).to receive(:new).and_return(double(perform: []))
    allow(Octokit::Client).to receive(:new).and_return(github)

    rebase = Rebase.where(github_id: pull_request['id']).first_or_initialize
    rebase.update_with_payload(payload: payload)

    expect(described_class.new.perform(payload))
  end

  it { expect(Rebase.find_by(github_id: pull_request['id']).state).to eq('closed') }
end
