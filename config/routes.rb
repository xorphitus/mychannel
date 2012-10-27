Mychannel::Application.routes.draw do
  root to: 'channels#index'
  resource :session, only: %w(new create destroy)
  resources :channels, only: %w(index, show)
  resources :voices, only: %w(show)
end
