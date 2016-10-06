require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  subject { response }

  describe 'GET #index' do
    context 'when user present' do
      let(:user) { create(:user) }

      before do
        allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
        get :index
      end

      it { is_expected.to redirect_to(projects_path) }
    end

    context 'when user missing' do
      before do
        allow_any_instance_of(described_class).to receive(:current_user).and_return(false)
        get :index
      end

      it { is_expected.to have_http_status(:success) }
    end
  end

  describe 'GET #show' do
    before { get :show, params: { page: 'contact' } }

    it { is_expected.to have_http_status(:ok) }
  end
end
