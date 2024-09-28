class UserMailer < ApplicationMailer
  def reset_password_link(user, token)
    @user = user
    @token = Base64.urlsafe_encode64(token)
    mail to: user.email, subject: 'Reset Your Password'
  end
end
