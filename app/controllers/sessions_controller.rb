class SessionsController < ApplicationController
  before_action :authenticate_user, :only => [:home, :profile, :setting, :logout]
  before_action :save_login_state, :only => [:login, :login_attempt]
  skip_before_action :verify_authenticity_token, :only => [:ipn_notification]

  def forgot_password
  end

  def sign_up
    @values = {}
    @values_trial = {}
  end

  def create_company
    @values_trial = {}
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
      @company = Company.new({:name => params[:company_name]})

      if @company.save
        @role = Role.new({:role_name => 'admin', :company_id => @company.id, :dashboard => 'admin', :permissions => '00233'})
        @role.save
        @user = User.new({:username => params[:username], :password => params[:password], :password_confirmation => params[:password2], :email => params[:email], :role => @role.dashboard.capitalize, :company_id => @company.id, :role_id => @role.id})

        if @user.save
          @subscription = Subscription.new({:company_id => @company.id, :status => 'not-verified', :profile_id => nil})
          if @subscription.save
            @payment = Payment.new({:subscription_id => @subscription.id, :amount => 0, :due_date => DateTime.now.next_month, :transID => nil})
            if @payment.save
                
              ppr = PayPal::Recurring.new({
                :return_url   => request.base_url + '/payments/return/' + @company.id.to_s,
                :cancel_url   => request.base_url + '/payments/cancel/' + @company.id.to_s,
                :ipn_url      => request.base_url + '/payments/ipn_notification/' + @company.id.to_s,
                :description  => "Awesome - Monthly Subscription",
                :amount       => "99.00",
                :currency     => "USD"
              })

              response = ppr.checkout

              if response.valid?
                redirect_to response.checkout_url
              else
                @company.destroy
                @errors['Paypal'] = 'recurring error!'
              end

            else
              @company.destroy
              @errors['Payment'] = ' error in save!'
              render sign_up
            end
          else
            @company.destroy
            @errors['Subscription'] = ' error in save!'
            render sign_up
          end
        else
          @company.destroy
          @errors['User'] = ' error in save!'
          render sign_up
        end
      else
        @errors['Company'] = ' error in save!'
        render sign_up
      end
    end
  end

  def trial
    @values = {}
    @errors_trial = Hash.new
    if params[:company_name].blank?
      @errors_trial['Company name'] = " can't be blank!"
    end
    if Company.exists?(:name => params[:company_name])
      @errors_trial['Company name'] = ' already taken!'
    end
    if params[:username].blank?
      @errors_trial['Username'] = " can't be blank!"
    end
    if User.exists?(:username => params[:username])
      @errors_trial['Username'] = ' already taken!'
    end
    if params[:password].blank?
      @errors_trial['Password'] = " can't be blank!"
    end
    if params[:password2].blank?
      @errors_trial['Password confimartion'] = " can't be blank!"
    end
    if params[:email].blank?
      @errors_trial['Email'] = " can't be blank!"
    end
    if params[:password] != params[:password2]
      @errors_trial['Password'] = " confirmation doesn't match!"
    end
    if params[:email].present?
      if !params[:email].match(/\A.+@.+\.+.+\z/)
        @errors_trial['Email'] = " invalid format!"
      end
    end
  
    @values_trial = params 

    if @errors_trial.length > 0
      render 'sign_up'
    else
     @company = Company.new({:name => params[:company_name]})

      if @company.save
        @role = Role.new({:role_name => 'admin', :company_id => @company.id, :dashboard => 'admin', :permissions => '00233'})
        @role.save
        @user = User.new({:username => params[:username], :password => params[:password], :password_confirmation => params[:password2], :email => params[:email], :role => @role.dashboard.capitalize, :company_id => @company.id, :role_id => @role.id})

        if @user.save
          @subscription = Subscription.new({:company_id => @company.id, :status => 'not-verified', :profile_id => nil})
          if @subscription.save
            @payment = Payment.new({:subscription_id => @subscription.id, :amount => 0, :due_date => DateTime.now.next_day, :transID => nil})
            if @payment.save
              render 'trial'
            else
              @company.destroy
              @errors['Payment'] = ' error in save!'
              render sign_up
            end
          else
            @company.destroy
            @errors['Subscription'] = ' error in save!'
            render sign_up
          end
        else
          @company.destroy
          @errors['User'] = ' error in save!'
          render sign_up
        end
      else
        @company.destroy
        @errors['Company'] = ' error in save!'
        render sign_up
      end
    end
  end

  def return
    @company = Company.find(params[:company_id])
    ppr = PayPal::Recurring.new({
      :token       => params[:token],
      :payer_id    => params[:PayerID],
      :amount      => "99.00",
      :description => "Awesome - Monthly Subscription"
    })
    response = ppr.request_payment
    if response.approved?
     if response.completed?
      ppr = PayPal::Recurring.new({
        :amount      => "99.00",
        :currency    => "USD",
        :description => "Awesome - Monthly Subscription",
        :ipn_url     => request.base_url + '/payments/ipn_notification/' + @company.id.to_s,
        :frequency   => 1,
        :token       => params[:token],
        :period      => :monthly,
        :reference   => "1234",
        :payer_id    => params[:PayerID],
        :start_at    => Time.now,
        :failed      => 1,
        :outstanding => :next_billing
      })

      response = ppr.create_recurring_profile
      subscription = Subscription.find_by(:company_id => params[:company_id])
      subscription.update_attribute(:profile_id, response.profile_id)
      if Payment.exists?(:subscription_id => subscription.id, :transID => nil)
        payment = Payment.find_by(:subscription_id => subscription.id, :transID => nil)
        payment.update_attribute(:amount, 99)
        payment.update_attribute(:transID, 'first_trans')
        subscription.update_attribute(:status, 'verified')
      end
    else
      @company.destroy
      render 'cancel'
    end
  else
    @company.destroy
    render 'cancel'
  end
    
  end

  def cancel
    @company = Company.find(params[:company_id])
    @company.destroy
  end

  def ipn_notification
    par = params
    response = validate_IPN(request.raw_post)
    case response
      when "VERIFIED"
        if params[:status] == 'COMPLETED' && Company.exists?(:id => par[:company_id])
          company = Company.find(par[:company_id])
          subscription = Subscription.find_by(:company_id => company.id)
          if Payment.exists?(:subscription_id => subscription.id, :transID => nil)
            payment = Payment.find_by(:subscription_id => subscription.id, :transID => nil)
            payment.update_attribute(:amount, 99)
            payment.update_attribute(:transID, params[:transaction]['0']['.id'])
            subscription.update_attribute(:status, 'verified')
          end
        end
      when "INVALID"
        puts 'Invalid IPN!'
      else
        puts 'Validation error!'
    end
    head :no_content

  end

  def validate_IPN(raw)
    uri = URI.parse('https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
    response = http.post(uri.request_uri, raw,
                         'Content-Length' => "#{raw.size}",
                         'User-Agent' => "My custom user agent"
                       ).body
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
      if authorized_user.type != 'Superuser'
        role = Role.find(authorized_user.role_id)
        subscription = Subscription.find_by(:company_id => authorized_user.company_id)
        if subscription
          payments = Payment.where(:subscription_id => subscription.id).order(:due_date => 'desc').first

          if subscription.status != 'suspended'
            if DateTime.now > payments.due_date 
              if subscription.status == 'not-verified'
                subscription.update_attribute(:status, 'suspended')
                flash[:notice] = "Your company has been suspended!"
                flash[:color] = "invalid"
                redirect_to :action => 'logout'
                return
              end
              if subscription.status == 'verified'
                subscription.update_attribute(:status, 'not-verified')
                superuser = User.find_by(:type => 'Superuser')
                message = Message.new({:sender_id => superuser.id, :recipient_id => authorized_user.id, :subject => 'Payment validation', :content => 'Please verify your payment transaction!', :status => 'sent'})
                message.save
              end
            else 
              if role.role_name == 'admin'
                if subscription
                  if subscription.status == 'not-verified'
                    superuser = User.find_by(:type => 'Superuser')
                    message = Message.new({:sender_id => superuser.id, :recipient_id => authorized_user.id, :subject => 'Payment validation', :content => 'Please verify your payment transaction!', :status => 'sent'})
                    message.save
                  end
                end
              end
            end
          else
            flash[:notice] = "Your company has been suspended!"
            flash[:color] = "invalid"
            redirect_to :action => 'logout'
            return
          end
        end
        redirect_to(:action => 'home')
        return
      else
  		  redirect_to(:action => 'home')
        return
      end
  	else
  		flash[:notice] = "Invalid username or password!"
  		flash[:color] = "invalid"
  		redirect_to root_path
  	end
  end

end