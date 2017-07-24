Rails.application.routes.draw do


  get 'dashboards/index'

  match 'sessions/forgot_password', :to => 'sessions#forgot_password' , :via => [:get, :post]

  match 'work_days/start_work_day', :to => 'work_days#start_work_day' , :via => [:get, :post]

  match 'work_days/finish_work_day', :to => 'work_days#finish_work_day' , :via => [:get, :post]

  match 'sessions/profile', :to => 'sessions#profile' , :via => [:get, :post]

  match 'sessions/change_email', :to => 'users#change_email' , :via => [:get, :post]

  match 'sessions/change_password', :to => 'users#change_password' , :via => [:get, :post]

  match 'reports/filter', :to => 'reports#filter' , :via => [:get, :post]

  match 'reports/by_user', :to => 'reports#by_user' , :via => [:get, :post]

  match 'reports/by_project', :to => 'reports#by_project' , :via => [:get, :post]

  match 'reports/get_gantt', :to => 'reports#get_gantt' , :via => [:get, :post]

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

  resources :work_days

  resources :notes

	resources :projects

	resources :projects do
		resources :tasks
  end
  
	match ':controller(/:action(/:id))(.:format)', :to => 'controller#action', :via => [:get, :post]

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
