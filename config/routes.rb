Rails.application.routes.draw do
  root 'welcome#index'
  get ':page', to: 'welcome#show', constraints: { page: /contact/ }, as: :page
  get 'callback', to: 'sessions#create'
  resources :projects
  post 'webhook', to: 'rebases#create', as: :webhook
  resources :rebase, only: [:edit, :update], controller: :rebases
end
