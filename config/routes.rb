Rails.application.routes.draw do


  get 'dashboards/index'

  match 'calendars/destroy', :to => 'events#destroy', :via => [:get, :post]

  match 'calendars/get_event_info', :to => 'calendars#get_event_info', :via => [:get, :post]

  match 'payments/return/(*company_id)', :to => 'sessions#return', :via => [:get, :post]

  match 'payments/cancel/(*company_id)', :to => 'sessions#cancel', :via => [:get, :post]

  match 'payments/ipn_notification/(*company_id)', :to => 'sessions#ipn_notification', :via => [:get, :post]

  match 'messages/set_read', :to => 'messages#set_read', :via => [:get, :post]

  match 'messages/reply', :to => 'messages#reply', :via => [:get, :post]

  match 'users/profile', :to => 'users#profile', :via => [:get, :post]

  match 'users/get_user_fields', :to => 'users#get_user_fields', :via => [:get, :post]
  
  match 'projects/milestone_edit', :to => 'projects#milestone_edit', :via => [:get, :post]

  match 'get_user_fields', :to => 'users#get_user_fields', :via => [:get, :post]

  match 'users/(*user_id)/get_user_fields', :to => 'users#get_user_fields', :via => [:get, :post]

  match 'projects/remove_user', :to => 'projects#remove_user', :via => [:get, :post]

  match 'projects/add_user', :to => 'projects#add_user', :via => [:get, :post]

  match 'sessions/forgot_password', :to => 'sessions#forgot_password' , :via => [:get, :post]

  match 'work_days/un_end_work_day', :to => 'work_days#un_end_work_day' , :via => [:get, :post]

  match 'work_days/start_work_day', :to => 'work_days#start_work_day' , :via => [:get, :post]

  match 'work_days/finish_work_day', :to => 'work_days#finish_work_day' , :via => [:get, :post]

  match 'sessions/create_company', :to => 'sessions#create_company' , :via => [:get, :post]

  match 'sessions/sign_up', :to => 'sessions#sign_up' , :via => [:get, :post]

  match 'sessions/profile', :to => 'sessions#profile' , :via => [:get, :post]

  match 'sessions/change_email', :to => 'users#change_email' , :via => [:get, :post]

  match 'sessions/change_password', :to => 'users#change_password' , :via => [:get, :post]

  match 'reports/by_user', :to => 'reports#by_user' , :via => [:get, :post]

  match 'reports/by_project', :to => 'reports#by_project' , :via => [:get, :post]

  match 'reports/get_gantt', :to => 'reports#get_gantt' , :via => [:get, :post]

  match 'notes/index', :to => 'notes#index' , :via => [:get, :post]

  match 'tasks/search', :to => 'tasks#search' , :via => [:get, :post]
  
  match 'projects/search', :to => 'projects#search' , :via => [:get, :post]

  match 'users/search', :to => 'users#search' , :via => [:get, :post]

  match 'users/index', :to => 'users#index' , :via => [:get, :post]

  match 'tasks/index/:advanced_search_id', :to => 'tasks#index' , :via => [:get, :post]

  match 'tasks/index', :to => 'tasks#index' , :via => [:get, :post]

  match 'projects/index', :to => 'projects#index' , :via => [:get, :post]

  match 'tasks/start_task', :to => 'tasks#start_task' , :via => [:get, :post]

  match 'tasks/pause_task', :to => 'tasks#pause_task' , :via => [:get, :post]

  match 'tasks/finish_task', :to => 'tasks#finish_task' , :via => [:get, :post]

  resources :users

  root :to => "sessions#login"

	get 'welcome/index'

  resources :companies

  resources :dashboards

  resources :milestones

  resources :advanced_searches

  resources :work_days

  resources :notes

  resources :role_fields

	resources :projects

  resources :roles

  resources :messages

  resources :events


  resources :tasks do
    resources :comments
  end

	resources :projects do
		resources :tasks
  end
  
	match ':controller(/:action(/:id))(.:format)', :to => 'controller#action', :via => [:get, :post]

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
