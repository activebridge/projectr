require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:repos).dependent(:delete_all) }
    it { is_expected.to have_many(:rebases).through(:repos) }
  end
end
