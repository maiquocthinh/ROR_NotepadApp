Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "app#index"

  # Panel routes
  get "/panel" => "panel#index"
  get "/panel/login" => "panel#login"
  post "/panel/login" => "panel#login_handler"
  get "/panel/register" => "panel#register"
  post "/panel/register" => "panel#register_handler"
  get "/panel/forgot-password" => "panel#forgot_password", as: :panel_forgot_password
  post "/panel/forgot-password" => "panel#forgot_password_handler"
  get "/panel/reset-password/:token" => "panel#reset_password", as: :panel_reset_password
  post "/panel/reset-password/:token" => "panel#reset_password_handler"
  get "/panel/logout" => "panel#logout"
  get "/panel/captcha" => "panel#captcha"
  get "/panel/*path" => redirect("/panel")

  # App routes
  get "/" => "app#note_write"
  get "/:slug" => "app#note_write"
  get "/login/:slug" => "app#note_login"
  get "/login/:share_type/:external_slug" => "app#note_login"
  get "/share/:external_slug" => "app#note_share"
  get "/raw/:external_slug"  => "app#note_raw"
  get "/code/:external_slug"  => "app#note_code"
  get "/markdown/:external_slug"  => "app#note_markdown"
  get "/user-backup/:backup_note_id" => "app#note_backup"
  match "/404", to: "app#not_found", via: :all

  # Api routes
  post "/api/note/login" => "api#note_login"
  delete "/api/note/logout" => "api#note_logout"
  post "/api/note/change-slug/:note_id" => "api#note_change_slug"
  post "/api/note/set-password/:note_id" => "api#note_set_password"
  delete "/api/note/delete/:note_id" => "api#note_delete"
  post "/api/note/backup/:note_id" => "api#note_backup"
  get "/api/note/download/:note_id" => "api#note_download"

  delete "/api/backup-note/delete/:backup_note_id" => "api#backup_note_delete"
  get "/api/backup-note/download/:backup_note_id" => "api#backup_note_download"

  post "/api/auth/revoke-session" => "api#auth_revoke_session"

  patch "/api/user" => "api#user_update"
end
