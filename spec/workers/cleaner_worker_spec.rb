require 'rails_helper'

RSpec.describe CleanerWorker, type: :job do
  let!(:user) { create(:user) }
  let(:repo) { create(:repo, user: user) }
  let(:admin_repo) { build(:admin_repo, permissions: double(admin: true)) }
  let(:git_repo) { build(:git_repo) }
  let(:collaborator) { double(id: 258) }
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
      add_deploy_key: deploy_key,
      remove_deploy_key: deploy_key,
      remove_hook: webhook
    )
  end

  before do
    allow(Sidekiq::Client).to receive(:enqueue_to).and_return(double(jid: 123))
    allow(RefresherWorker).to receive(:new).and_return(double(perform: []))
    allow(Octokit::Client).to receive(:new).and_return(github)
    expect(described_class.new.perform(repo.name, user))
  end

  context 'deletes ssh key' do
    let(:ssh_path) { File.expand_path("#{ENV['key_path']}/id_rsa.#{repo.name}") }
    it { expect(File.file?(ssh_path)).to be_falsey }
  end

  context 'clears config file' do
    let(:content) { SSH::SSH_CONFIG % { name: repo.name.parameterize } }
    let(:file_path) { File.expand_path("#{ENV['key_path']}/config") }
    it { expect(File.read(file_path)).not_to include(content) }
  end
end
