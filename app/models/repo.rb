class Repo < ApplicationRecord
  SSH_CONFIG = %(
    Host %{name} github.com
    Hostname github.com
    IdentityFile ~/.ssh/id_rsa.%{name}
  ).freeze

  belongs_to :user
  has_many :rebases, primary_key: :name, foreign_key: :repo, class_name: 'Rebase'

  validates :name, :ssh, presence: true, uniqueness: true

  after_create :generate_ssh

  private

  def generate_ssh
    Timeout.timeout(1) do
      `ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa.#{name.parameterize}`
      config = SSH_CONFIG % { name: name.parameterize }
      `echo "#{config}" >> ~/.ssh/config`
    end
  end
end
