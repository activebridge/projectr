Rails.application.routes.draw do
  root 'welcome#index'
  get ':page', to: 'welcome#show', constraints: { page: /contact/ }, as: :page
  get 'callback', to: 'sessions#create'
  resources :projects do
    resource :test_message, only: :create, controller: 'projects/test_messages'
  end
  post 'webhook', to: 'rebases#create', as: :webhook
  resources :rebase, only: [:edit, :update], controller: :rebases
end
