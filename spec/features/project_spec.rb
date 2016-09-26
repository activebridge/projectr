require 'rails_helper'

feature 'Project' do
  let!(:user) { create(:user) }
  let(:admin_repo) do
    double(
      full_name: FFaker::Name.name.parameterize,
      permissions: double(admin: true),
      created_at: 1.day.ago
    )
  end
  let(:git_repo) do
    {
      'ssh_url' => "git@github.com:#{admin_repo.full_name}.git",
      'default_branch' => 'master'
    }
  end
  let(:collaborator) { double(id: 258) }
  let(:webhook) do
    {
      'type' => 'Repository',
      'name' => 'web',
      'events' => %w(push pull_request),
      'config' => { 'url' => 'http://3deec0f4.ngrok.io/webhook' }
    }
  end
  let(:deploy_key) do
    {
      'key' => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLpt',
      'title' => 'ProjectR'
    }
  end
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
  let(:projects_page) { ProjectPage.new(projects_path) }

  before do
    page.set_rack_session(user_id: user.id)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow(Octokit::Client).to receive(:new).and_return(github)
    allow(RefresherJob).to receive(:new).and_return(double(perform: []))
    allow(CleanerJob).to receive(:perform_later).and_return([])
  end

  scenario 'Visit Projects index' do
    projects_page.open
    expect(page).to have_css('span.head__title')
  end

  scenario 'Create project' do
    projects_page.open
    projects_page.open_repo
    expect(page).to have_text(admin_repo.full_name)
  end

  describe 'When project present' do
    let(:repo) { create(:repo, user: user, name: admin_repo.full_name) }

    scenario 'Show project' do
      visit "projects/#{repo.name}"
      expect(page).to have_text(repo.name)
    end

    scenario 'Update project' do
      visit "projects/#{repo.name}"
      projects_page.update_repo
      expect(find(:css, '#repo_auto_rebase').checked?).to eq(true)
    end

    scenario 'Destroy project' do
      visit "projects/#{repo.name}"
      projects_page.destroy_repo
      expect(page).to have_css('span.head__title')
    end
  end
end
