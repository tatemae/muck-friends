Rails.application.routes.draw do
  resources :friends, :controller => 'muck/friends'
  resources :users do
    resources :friends, :controller => 'muck/friends'
  end
end
