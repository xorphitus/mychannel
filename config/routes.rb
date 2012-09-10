Mychannel::Application.routes.draw do
  scope "edit" do
    resources :users, only: [:create, :update]
    resources :channels
    resources :topics
  end

  root :to => 'login#index'

  match 'dashboard' => 'dashboard#index'

  match 'voice' => 'voices#emit'
  match 'story' => 'stories#emit'
end
