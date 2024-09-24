class PanelController < ApplicationController
  def index

  end

  def login

  end

  def login_handler
  end

  def register

  end

  def register_handler
    registration_request = AuthRegisterRequest.new(
      params.permit(:email, :username, :password, :confirm_password)
    )

    if registration_request.valid?
      hashed_password = BCrypt::Password.create(registration_request.password)
      user = User.new(
        email: registration_request.email,
        username: registration_request.username,
        hash_password: hashed_password
      )

      if user.save
        flash.now[:success] = { message: "Register success. Go login!" }
        render "register"
      else
        flash.now[:errors] = user.errors.full_messages
        render "register"
      end
    else
      flash.now[:errors] = registration_request.errors.full_messages
      render "register"
    end
  end

  def forgot

  end

  def reset_password

  end

  def captcha
    captcha = SimpleCaptcha::SimpleCaptcha.generate
    session[:captcha] = captcha.value
    send_data captcha.image, type: 'image/png', disposition: 'inline'
  end
end
