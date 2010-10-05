Rails.application.routes.draw do
  map.resources :friends, :controller => 'muck/friends'
  map.resources :users do |users|
    users.resources :friends, :controller => 'muck/friends'
  end
end
