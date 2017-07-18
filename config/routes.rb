Rails.application.routes.draw do
  get 'dashboards/index'

  match 'notes/index', :to => 'notes#index' , :via => [:get, :post]

  match 'tasks/search', :to => 'tasks#search' , :via => [:get, :post]
  
  match 'projects/search', :to => 'projects#search' , :via => [:get, :post]

  match 'users/search', :to => 'users#search' , :via => [:get, :post]

  match 'users/index', :to => 'users#index' , :via => [:get, :post]

  match 'tasks/index', :to => 'tasks#index' , :via => [:get, :post]

  match 'projects/index', :to => 'projects#index' , :via => [:get, :post]

  match 'tasks/start_task', :to => 'tasks#start_task' , :via => [:get, :post]

  match 'tasks/pause_task', :to => 'tasks#pause_task' , :via => [:get, :post]

  match 'tasks/finish_task', :to => 'tasks#finish_task' , :via => [:get, :post]

  resources :users

  root :to => "sessions#login"

	get 'welcome/index'

  resources :notes

	resources :projects

	resources :projects do
		resources :tasks
  end
  
	match ':controller(/:action(/:id))(.:format)', :to => 'controller#action', :via => [:get, :post]

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
