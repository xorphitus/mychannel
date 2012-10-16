Mychannel::Application.routes.draw do
  root to: 'sessions#new'
  resource :session, only: %w(new, create, destroy)
  resources :dashboard, only: %w(index)
  resources :voices, only: %w(show)
  resources :stories, only: %w(show)
end
