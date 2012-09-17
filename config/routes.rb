Mychannel::Application.routes.draw do
  scope "edit" do
    resources :topics, except: :index
    resources :users, only: [:create, :update]
    resources :channels do
      resources :topics, except: :index
    end
  end

  root :to => 'login#index'
  match 'logout' => 'logout#index'

  match 'dashboard' => 'dashboard#index'

  match 'voice' => 'voices#emit'
  match 'story' => 'stories#emit'
end
