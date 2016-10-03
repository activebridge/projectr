require 'rails_helper'

RSpec.describe CleanerJob, type: :job do
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
  let(:content) do
    "\nHost #{repo.name} github.com
    Hostname github.com
    IdentityFile ~/.ssh/id_rsa.#{repo.name}\n \n\n"
  end
  let(:file_path) { File.expand_path('~/.ssh/config') }
  let(:ssh_path) { File.expand_path("~/.ssh/id_rsa.#{repo.name}") }

  before do
    allow(RefresherJob).to receive(:new).and_return(double(perform: []))
    allow(Octokit::Client).to receive(:new).and_return(github)
    expect(described_class.perform_now(repo.name, user))
  end

  context 'deletes ssh key' do
    it { expect(File.file?(ssh_path)).to be_falsey }
  end

  context 'clears config file' do
    it { expect(File.read(file_path)).not_to include(content) }
  end
end
