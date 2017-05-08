class Rebase < ApplicationRecord
  belongs_to :repository, class_name: 'Repo', foreign_key: :repo, primary_key: :name

  validates :base, :head, :sha, presence: true

  delegate :user, to: :repository
  delegate :name, to: :repository, prefix: true

  def update_with_payload(attributes)
    initialize_payload_value(attributes[:payload])
    assign_attributes(attributes.except(:payload))
    save
  end

  def self.update_pull_state(payload)
    rebase = find_by_github_id(payload['pull_request']['id'])
    rebase.update_attributes(state: payload['pull_request']['state']) if rebase
  end

  private

  def initialize_payload_value(payload)
    self.repo = payload['repository']['full_name']
    pr = payload['pull_request']
    self.base = pr['base']['ref']
    self.head = pr['head']['ref']
    self.sha = pr['head']['sha']
    self.state = pr['state']
    self.number = pr['number']
    self.title = pr['title']
  end
end
