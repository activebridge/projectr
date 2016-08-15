require 'rails_helper'

RSpec.describe Repo, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:ssh) }
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
