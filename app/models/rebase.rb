class Rebase < ApplicationRecord
  belongs_to :repository, class_name: 'Repo', foreign_key: :repo, primary_key: :name

  validates :base, :head, :sha, presence: true

  delegate :user, to: :repository

  def self.from_payload(payload)
    r = new
    r.repo = payload['repository']['full_name']
    r.base = payload['pull_request']['base']['ref']
    r.head = payload['pull_request']['head']['ref']
    r.sha = payload['pull_request']['head']['sha']
    r.save!
    r
  end
end
