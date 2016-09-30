require 'rails_helper'

RSpec.describe Repo, type: :model do
  let(:git_repo) { build(:git_repo) }
  let(:collaborator) { double(id: 258) }
  let(:github) { double(repo: git_repo, collaborators: [collaborator]) }

  describe 'validates' do
    before do
      allow_any_instance_of(User).to receive(:github).and_return(github)
    end

    subject { Repo.new(user: create(:user)) }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it do
      is_expected.to have_many(:rebases)
        .class_name('Rebase')
        .with_foreign_key(:repo)
        .with_primary_key(:name)
    end
  end
end
