Mychannel::Application.routes.draw do
  root to: 'sessions#new'
  resource :session, only: ['new', 'destroy']
  resources :dashboard, only: ['index']
  resources :voices, only: ['show']
  resources :stories, only: ['show']
end
