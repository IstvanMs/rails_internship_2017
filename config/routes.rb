Rails.application.routes.draw do

  resources :users

  root :to => "sessions#login"
  
  match ':controller(/:action(/:id))(.:format)', :to => 'controller#action', :via => [:get, :post]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
