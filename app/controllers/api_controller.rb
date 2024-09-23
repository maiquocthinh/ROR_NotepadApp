class ApiController < ApplicationController
  # Note actions
  def note_login
    render plain: "note_login"
  end

  def note_logout
    render plain: "note_logout"
  end

  def note_change_slug
    render plain: "note_change_slug"
  end

  def note_set_password
    render plain: "note_set_password"
  end

  def note_delete
    render plain: "note_delete"
  end

  def note_backup
    render plain: "note_backup"
  end

  def note_download
    render plain: "note_download"
  end

  # Backup note actions
  def backup_note_delete
    render plain: "backup_note_delete"
  end

  def backup_note_download
    render plain: "backup_note_download"
  end

  # Auth actions
  def auth_revoke_session
    render plain: "auth_revoke_session"
  end

  def auth_login
    render plain: "auth_login"
  end

  def auth_register
    render plain: "auth_register"
  end

  def auth_logout
    render plain: "auth_logout"
  end

  def auth_forgot_password
    render plain: "auth_forgot_password"
  end

  def auth_reset_password
    render plain: "auth_reset_password"
  end

  # User actions
  def user_update
    render plain: "user_update"
  end
end
