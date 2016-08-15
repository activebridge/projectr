require 'rails_helper'

RSpec.describe Rebase, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to(:repository)
        .class_name('Repo')
        .with_foreign_key(:repo)
        .with_primary_key(:name)
    end
  end

  describe 'validates' do
    it { is_expected.to validate_presence_of(:base) }
    it { is_expected.to validate_presence_of(:head) }
    it { is_expected.to validate_presence_of(:sha) }
  end

  describe 'delegate' do
    it { is_expected.to delegate_method(:user).to(:repository) }
    it { is_expected.to delegate_method(:name).to(:repository).with_prefix }
  end
end
