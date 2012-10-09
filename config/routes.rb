Mychannel::Application.routes.draw do
  root to: 'login#index'
  resources :logout, only: ['index']
  resources :dashboard, only: ['index']
  resources :voices, only: ['show']
  resources :stories, only: ['show']
end
