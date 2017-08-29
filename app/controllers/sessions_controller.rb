class SessionsController < ApplicationController
  before_action :authenticate_user, :only => [:home, :profile, :setting, :logout]
  before_action :save_login_state, :only => [:login, :login_attempt]
  skip_before_action :verify_authenticity_token, :only => [:ipn_notification]

  def forgot_password
  end

  def sign_up
    @values = {}
  end

  def create_company
    @errors = Hash.new
    if params[:company_name].blank?
      @errors['Company name'] = " can't be blank!"
    end
    if Company.exists?(:name => params[:company_name])
      @errors['Company name'] = ' already taken!'
    end
    if params[:username].blank?
      @errors['Username'] = " can't be blank!"
    end
    if User.exists?(:username => params[:username])
      @errors['Username'] = ' already taken!'
    end
    if params[:password].blank?
      @errors['Password'] = " can't be blank!"
    end
    if params[:password2].blank?
      @errors['Password confimartion'] = " can't be blank!"
    end
    if params[:email].blank?
      @errors['Email'] = " can't be blank!"
    end
    if params[:password] != params[:password2]
      @errors['Password'] = " confirmation doesn't match!"
    end
    if params[:email].present?
      if !params[:email].match(/\A.+@.+\.+.+\z/)
        @errors['Email'] = " invalid format!"
      end
    end
  
    @values = params    

    if @errors.length > 0
      render 'sign_up'
    else
      pay_request = PaypalAdaptive::Request.new

      data = {
      "returnUrl" => "http://localhost:3000/", 
      "requestEnvelope" => {"errorLanguage" => "en_US"},
      "currencyCode"=>"USD",  
      "receiverList"=>{"receiver"=>[{"email"=>"meszarosistvan97-facilitator@gmail.com", "amount"=>"99.00"}]},
      "cancelUrl"=>"http://localhost:3000/",
      "actionType"=>"PAY",
      "ipnNotificationUrl"=>"http://localhost:3000/payments/ipn_notification"
      }

      pay_response = pay_request.pay(data)
      puts pay_response
    end
  end

  def ipn_notification
    puts params.inspect
  end

  def reset
    email = params[:email]
    if email == nil
      flash[:notice] = "Empty email field!"
      flash[:color] = "invalid"
      redirect_to(:action => 'forgot_password')
    else
      if !User.exists?(:email => email)
        flash[:notice] = "Wrong email!"
        flash[:color] = "invalid"
        redirect_to(:action => 'forgot_password')
      else
        @user = User.find_by(:email => email)
        password = rand(36**8).to_s(36)
        @user.password = password
        @user.encrypt_password
        if @user.save
          flash[:notice] = "Password reseted!"
          flash[:color] = "valid"
          #send email with the new password
          redirect_to(:action => 'login')
        else
          flash[:notice] = "Error in update!"
          flash[:color] = "invalid"
          redirect_to(:action => 'forgot_password')
        end 
      end
    end
  end

  def login
  end

  def home
    redirect_to dashboards_index_path
  end

  def profile
    @user = User.find(@current_user.id)
    @user_fields = UserField.where(:user_id => @user.id)
    if @user.type == 'Superuser'
      @role = "Superuser"
    else
      @role = Role.find(@user.role_id)
    end
      render 'users/show'
  end

  def setting
  end

  def logout
  	session[:user_id] = nil
    session[:reports_year] = nil
    session[:reports_month] = nil
    session[:reports_user] = nil
  	redirect_to :action => 'login'
  end

  def login_attempt
  	authorized_user = User.authenticate(params[:username],params[:login_password])

  	if authorized_user
  		session[:user_id] = authorized_user.id
  		redirect_to(:action => 'home')
  	else
  		flash[:notice] = "Invalid username or password!"
  		flash[:color] = "invalid"
  		redirect_to root_path
  	end
  end

end