Rails.application.routes.draw do
  root 'welcome#index'
  get ':page', to: 'welcome#show', constraints: { page: /contact/ }, as: :page
  get 'callback', to: 'sessions#create'
  post 'webhook', to: 'rebases#create', as: :webhook

  resources :projects do
    resource :test_message, only: :create, controller: 'projects/test_messages'
  end

  resources :sessions, only: [:new, :create] do
    delete :destroy, on: :collection
  end

  resources :rebase, only: [:edit, :update], controller: :rebases
end
