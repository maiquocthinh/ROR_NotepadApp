class PanelController < ApplicationController
  include AccessChecker

  before_action :check_panel_login

  def index
  end

  def login
  end

  def login_handler
    login_request = AuthLoginRequest.new(
      params.permit(:username, :password)
    )

    unless login_request.valid?
      flash.now[:errors] = login_request.errors.full_messages
      return render "login"
    end

    user = User.find_by(username: params[:username])

    unless user && BCrypt::Password.new(user.hash_password) == login_request.password
      flash.now[:errors] = ["Username or Password invalid!"]
      return  render "login"
    end

     # set session
    session[:user] = user.attributes.except('hash_password')
    session[:client] = ClientInfo.get_info_client(request)

    redirect_to panel_path
  end

  def register
  end

  def register_handler
    registration_request = AuthRegisterRequest.new(
      params.permit(:email, :username, :password, :confirm_password)
    )

    unless registration_request.valid?
      flash.now[:errors] = registration_request.errors.full_messages
      return render "register"
    end

    hashed_password = BCrypt::Password.create(registration_request.password)
    user = User.new(
      email: registration_request.email,
      username: registration_request.username,
      hash_password: hashed_password
    )

    unless user.save
      flash.now[:errors] = user.errors.full_messages
      return render "register"
    end

    flash.now[:success] = { message: "Register success. Go login!" }
    render "register"
  end

  def forgot_password
  end

  def reset_password
  end

  def captcha
    captcha = SimpleCaptcha::SimpleCaptcha.generate
    session[:captcha] = captcha.value
    send_data captcha.image, type: "image/png", disposition: "inline"
  end
end
