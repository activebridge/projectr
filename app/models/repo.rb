class Repo < ApplicationRecord
  include SSH
  belongs_to :user
  has_many :rebases, primary_key: :name, foreign_key: :repo, class_name: 'Rebase'

  validates :name, :ssh, presence: true, uniqueness: true

  after_create :generate_ssh
  after_destroy :destroy_ssh
end
