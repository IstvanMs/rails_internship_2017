class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected
  def authenticate_user
  	if session[:user_id]
	  	@current_user = User.find session[:user_id]
	  	return true
  	else
  		redirect_to(:controller => 'sessions', :action => 'login')
  		return false
  	end
  end

  def admin_user
    if authenticate_user
      if @current_user.role == 'Admin'
        return true
      else
        redirect_to(:controller => 'sessions', :action => 'home')
        return false
      end
    else 
      return false
    end
  end

  def manager_user
    if authenticate_user
      if @current_user.role == 'Manager'
        return true
      else
        redirect_to(:controller => 'sessions', :action => 'home')
        return false
      end
    else 
      return false
    end
  end

  def save_login_state
  	if session[:user_id]
  		redirect_to(:controller => 'sessions', :action => 'home')
  		return false
  	else
  		return true
  	end
  end
end
