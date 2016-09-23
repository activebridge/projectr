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

  private

  def initialize_payload_value(payload)
    self.repo = payload['repository']['full_name']
    pr = payload['pull_request']
    self.base = pr['base']['ref']
    self.head = pr['head']['ref']
    self.sha = pr['head']['sha']
    self.state = pr['state']
    self.number = pr['number']
  end
end
