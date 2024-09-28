Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'example.com',
  user_name:            ENV['GMAIL_APP_EMAIL'],
  password:             ENV['GMAIL_APP_PASSWORD'],
  authentication:       :plain,
  enable_starttls_auto: true,
  open_timeout:         5,
  read_timeout:         5
}