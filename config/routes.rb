Mychannel::Application.routes.draw do
  scope "edit" do
    resources :topics
    resources :channels
  end

  root :to => 'login#index'

  match 'dashboard' => 'dashboard#index'

  match 'voice' => 'voices#emit'
  match 'story' => 'stories#emit'
end
