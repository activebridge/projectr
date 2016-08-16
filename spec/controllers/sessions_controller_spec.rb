require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:user) { create(:user) }

  subject { response }

  describe 'POST #create' do
    let(:token) { 'token' }
    let(:github_user) { double(id: user.github_id, name: 'Name', login: 'Login', email: 'example@example.com', avatar_url: 'avatar') }

    context 'when authenticate successful' do
      before do
        allow_any_instance_of(ApplicationController).to receive(:github).and_return(double(exchange_code_for_token: double('[]': token)))

        allow(Octokit::Client).to receive(:new).and_return(double(user: github_user))

        post :create
      end

      it { expect(session[:user_id]).to eq(user.id) }
    end
  end
end
