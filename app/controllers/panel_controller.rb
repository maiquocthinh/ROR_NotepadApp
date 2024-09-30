class PanelController < ApplicationController
  include AccessChecker

  before_action :check_panel_login

  def index
    begin
      user_id = session[:user]["id"]

      user = User
               .includes(:notes, :backup_notes)
               .where(id: user_id)
               .references(:notes, :backup_notes)
               .order('notes.updated_at DESC, backup_notes.updated_at DESC')
               .first

      notes = user&.notes&.map do |note|
        note.as_json(only: [:id, :slug, :views, :need_password, :updated_at])
      end

      backup_notes = user&.backup_notes&.map do |backup_note|
        backup_note.as_json(only: [:id, :updated_at])
      end

      sessions = UserSessionManager.get_sessions(user_id).map do |_session|
        {
          session_id: _session["session_id"],
          user: _session["user"],
          client: _session["client"],
          is_this_session: _session["session_id"] == session.id.to_s
        }
      end

      render locals: {
        user: user&.as_json(except: [:notes, :backup_notes, :sessions]),
        notes: notes,
        backup_notes: backup_notes,
        sessions: sessions,
        # device_icons: DeviceIcons
      }
    rescue StandardError => e
      # render json: { error: e.message }, status: :bad_request
      raise e
    end

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

    user = User.find_by(username: login_request.username)

    unless user && BCrypt::Password.new(user.hash_password) == login_request.password
      flash.now[:errors] = ["Username or Password invalid!"]
      return render "login"
    end

    # set session
    session[:user] = user.attributes.except('hash_password')
    session[:client] = ClientInfo.get_info_client(request)
    UserSessionManager.add_session(user.id, session.id.to_s)

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

  def forgot_password_handler
    forgot_password_request = AuthForgotPasswordRequest.new(
      params.permit(:email)
    )

    unless forgot_password_request.valid?
      flash.now[:errors] = forgot_password_request.errors.full_messages
      return render "forgot_password"
    end

    user = User.find_by(email: forgot_password_request.email)

    unless user
      flash.now[:errors] = ["Account does not exist!"]
      return render "forgot_password"
    end

    token = JwtTokenManager::Create.reset_password({ username: user.username })

    UserMailer.reset_password_link(user, token).deliver_now

    flash.now[:success] = { message: "Reset Password link sent to your E-mail!" }
    render "forgot_password"
  end

  def reset_password
    token = params[:token]
    token = Base64.urlsafe_decode64(token)

    claims = JwtTokenManager::Verify.reset_password(token)

    unless claims
      flash.now[:errors] = ["Reset Password fail. Maybe this link is expired!"]
      return render "reset_password"
    end

    render "reset_password"
  end

  def reset_password_handler
    reset_password_request = AuthResetPasswordRequest.new(
      params.permit(:password, :confirm_password)
    )

    unless reset_password_request.valid?
      flash.now[:errors] = reset_password_request.errors.full_messages
      return render "reset_password"
    end

    token = params[:token]
    token = Base64.urlsafe_decode64(token)

    claims = JwtTokenManager::Verify.reset_password(token)

    unless claims
      flash.now[:errors] = ["Reset Password fail. Maybe this link is expired!"]
      return render "reset_password"
    end

    user = User.find_by(username: claims['username'])
    unless user
      flash.now[:errors] = ["Account does not exist!"]
      return render "reset_password"
    end

    hashed_password = BCrypt::Password.create(reset_password_request.password)

    unless user.update(hash_password: hashed_password)
      flash.now[:errors] = user.errors.full_messages
      return render "reset_password"
    end

    flash.now[:success] = { message: "Reset Password success. Go login!" }
    render "reset_password"
  end

  def logout
    user_id = session[:user]["id"]
    UserSessionManager.destroy_session(user_id, session.id.to_s)
    reset_session
    redirect_to panel_login_path
  end

  def captcha
    captcha = SimpleCaptcha::SimpleCaptcha.generate
    session[:captcha] = captcha.value
    send_data captcha.image, type: "image/png", disposition: "inline"
  end
end
