class Rebase < ApplicationRecord
  belongs_to :repository, class_name: 'Repo', foreign_key: :repo, primary_key: :name

  validates :base, :head, :sha, presence: true

  delegate :user, to: :repository
  delegate :name, to: :repository, prefix: true

  def update_from_payload(payload)
    self.repo = payload['repository']['full_name']
    self.base = payload['pull_request']['base']['ref']
    self.head = payload['pull_request']['head']['ref']
    self.sha = payload['pull_request']['head']['sha']
    self.state = payload['pull_request']['state']
    self.number = payload['pull_request']['number']
    save
  end
end
