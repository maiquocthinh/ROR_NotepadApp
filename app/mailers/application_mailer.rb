class ApplicationMailer < ActionMailer::Base
  default from: ENV["GMAIL_APP_EMAIL"]
  layout "mailer"
end
