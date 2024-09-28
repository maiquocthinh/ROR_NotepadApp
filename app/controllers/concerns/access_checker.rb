module AccessChecker
  extend ActiveSupport::Concern

  def check_panel_login

    if session[:user]
      if ["login", "register", "forgot_password", "reset_password" ].include?(action_name)
        return  redirect_to panel_path
      end
    else
      if action_name == "index"
        return redirect_to panel_login_path
      end
    end

  end
end
