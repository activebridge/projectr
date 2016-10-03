require 'rails_helper'

RSpec.describe RebasesController, type: :controller do
  let(:user) { create(:user) }
  let(:repo) { create(:repo, user: user) }
  let(:rebase) { create(:rebase, repo: repo.name) }
  let(:admin_repo) { build(:admin_repo, permissions: double(admin: true)) }
  let(:git_repo) { build(:git_repo) }
  let(:collaborator) { double(id: user.github_id) }
  let(:webhook) { build(:webhook) }
  let(:deploy_key) { build(:deploy_key) }
  let(:github) do
    double(
      repos: [admin_repo],
      collaborators: [collaborator],
      repo: git_repo,
      hooks:  [webhook],
      create_hook: webhook,
      deploy_keys: [deploy_key],
      add_deploy_key: deploy_key
    )
  end

  subject { response }

  before do
    allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
    allow(Octokit::Client).to receive(:new).and_return(github)
    allow(RefresherJob).to receive(:new).and_return(double(perform: []))
    allow(RebaserJob).to receive(:new).and_return(double(perform: []))
    allow(PusherJob).to receive(:new).and_return(double(perform: []))
  end

  describe 'POST #create' do
    context 'when event push' do
      let(:env) { { 'HTTP_X_GITHUB_EVENT' => 'push' } }
      let(:payload) do
        {
          'repository' => { 'full_name' => repo.name },
          'ref' => 'refs/heads/master'
        }
      end

      before do
        allow(JSON).to receive(:parse).and_return(payload)
        allow(request).to receive(:env).and_return(env)
        post :create
      end

      it { is_expected.to have_http_status(200) }
    end

    context 'when event pull_request' do
      let(:github_id) { rebase.github_id }
      let(:env) { { 'HTTP_X_GITHUB_EVENT' => 'pull_request' } }
      let(:payload) do
        {
          'pull_request' => { 'id' => rebase.github_id, 'state' => 'open' },
          'action' => 'opened'
        }
      end

      before do
        allow(JSON).to receive(:parse).and_return(payload)
        allow(request).to receive(:env).and_return(env)
        post :create
      end

      it { expect(Rebase.find_by(github_id: github_id).state).to eq('open') }
    end
  end

  describe 'PATCH #update' do
    context 'when user is collaborator' do
      before { patch :update, params: { id: rebase.id } }

      it { is_expected.to have_http_status(200) }
    end

    context 'when user is not collaborator' do
      let(:collaborator) { double(id: 0) }

      before { patch :update, params: { id: rebase.id } }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
