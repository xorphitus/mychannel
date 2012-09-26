Mychannel::Application.routes.draw do

  root :to => 'login#index'
  match 'logout' => 'logout#index'

  match 'dashboard' => 'dashboard#index'

  match 'voice' => 'voices#emit'
  match 'story' => 'stories#emit'
end
