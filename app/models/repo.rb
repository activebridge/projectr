class Repo < ApplicationRecord
  include SSH

  belongs_to :user
  has_many :rebases, primary_key: :name, foreign_key: :repo, class_name: 'Rebase', dependent: :destroy

  validates :name, :ssh, presence: true, uniqueness: true

  before_validation :set_github_data, on: :create
  after_create :generate_ssh, :init_project
  after_destroy :clean_project

  private

  def set_github_data
    self.ssh = git_repo['ssh_url']
    self.collaborators = git_collaborators
  end

  def init_project
    user.github.create_hook(name, 'web', { url: webhook }, { events: %w[push pull_request] }) unless hook_url
    user.github.add_deploy_key(name, 'ProjectR', ssh_key) unless deploy_key
  end

  def clean_project
    CleanerJob.perform_later(name, user)
  end

  def git_repo
    @git_repo ||= user.github.repo(name)
  end

  def git_collaborators
    @git_collaborators ||= user.github.collaborators(name).map(&:id)
  end

  def github_hooks
    @github_hooks ||= user.github.hooks(name)
  end

  def github_dkeys
    @github_dkeys ||= user.github.deploy_keys(name)
  end

  def webhook
    @webhook ||= Rails.application.routes.url_helpers.webhook_url(host: ENV['host'], port: nil)
  end

  def hook_url
    github_hooks.any? { |h| h['config']['url'] == webhook }
  end

  def deploy_key
    github_dkeys.any? { |d| d['key'] == ssh_key.split[0..1].join(' ') }
  end

  def ssh_key
    @ssh_key ||= `cat #{ENV['key_path']}/id_rsa.#{name.parameterize}.pub`.strip
  end
end
