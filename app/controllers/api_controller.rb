class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Note actions
  def note_login
    note_login_request = AuthNoteLoginRequest.new(
      params.permit(:slug, :external_slug, :password)
    )

    unless note_login_request.valid?
      return render json: { errors: note_login_request.errors.full_messages }, status: :bad_request
    end

    slug = note_login_request.slug
    external_slug = note_login_request.external_slug
    password = note_login_request.password
    note = nil

    begin
      if slug
        note = Note.find_by_slug(slug)

        raise 'Login into note fail!' unless note
        raise 'Login fail. This note does not have a password!' unless note.need_password

        # compare password of note
        unless BCrypt::Password.new(note.hash_password) == password
          raise 'Login fail. Password wrong!'
        end

        # update session notes_logged_in
        session[:notes_logged_in] ||= []
        session[:notes_logged_in] << slug unless session[:notes_logged_in].include?(slug)
      elsif external_slug
        note = Note.find_by_external_slug(external_slug)

        raise 'Login into note fail!' unless note
        raise 'Login fail. This note does not have a password!' unless note.need_password

        # compare password of note
        unless BCrypt::Password.new(note.hash_password) == password
          raise 'Login fail. Password wrong!'
        end

        # update session notes_logged_in
        session[:notes_logged_in] ||= []
        session[:notes_logged_in] << note.slug unless session[:notes_logged_in].include?(note.slug)
      else
        raise 'Login into note fail!'
      end

      render json: { message: 'Login into note success!' }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :bad_request
    end

  end

  def note_logout
    note_slug = params[:slug]

    raise 'Logout from note fail!' unless note_slug

    # remove noteSlug from notes_logged_in
    if session[:notes_logged_in].is_a?(Array)
      session[:notes_logged_in] = session[:notes_logged_in].reject { |logged_note_slug| logged_note_slug == note_slug }
    end

    render json: { message: 'Logout from note success!' }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :bad_request
  end

  def note_change_slug
    begin
      note_id = params[:note_id]
      slug = params[:slug]

      raise 'Change note slug fail!' unless note_id

      note = Note.find_by(id: note_id)
      raise 'Change note slug fail!' unless note

      note.slug = slug
      note.save!

      render json: { message: 'Change note slug success!' }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :bad_request
    end
  end

  def note_set_password
    note_id = params[:note_id]
    password = params[:password]

    begin
      raise 'Set password for note fail!' if note_id.blank?

      note = Note.find_by(id: note_id)
      raise 'Set password for note fail!' if note.nil?

      note.need_password = password.present?
      note.hash_password = password.present? ? BCrypt::Password.create(password) : nil

      note.save

      if password.present?
        render json: { message: 'Set password for note success!' }, status: :ok
      else
        render json: { message: 'Remove password from note success!' }, status: :ok
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :bad_request
    end
  end

  def note_delete
    note_id = params[:note_id]

    if note_id.blank?
      render json: { error: 'Delete note fail!' }, status: :bad_request
      return
    end

    note = Note.find_by(id: note_id)

    if note
      note.destroy
      render json: { message: 'Delete note success' }, status: :ok
    else
      render json: { error: 'Note not found' }, status: :bad_request
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def note_backup
    user_id = session[:user]["id"]
    note_id = params[:note_id]

    if note_id.blank?
      render json: { error: 'Backup note fail!' }, status: :bad_request
      return
    end

    note = Note.find_by(id: note_id)

    if note.nil?
      render json: { error: 'Backup note fail!' }, status: :bad_request
      return
    end

    BackupNote.create!(content: note.content, user_id: user_id)

    render json: { message: 'Backup note success' }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error

  end

  def note_download
    note_id = params[:note_id]

    if note_id.blank?
      render json: { error: 'Download backup note fail!' }, status: :bad_request
      return
    end

    backup_note = Note.find_by(id: note_id)

    if backup_note.nil?
      render json: { error: 'Download backup note fail!' }, status: :not_found
      return
    end

    # send download as .txt
    send_data backup_note.content, filename: "#{backup_note.id}.txt", type: 'text/plain'
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # Backup note actions
  def backup_note_delete
    backup_note_id = params[:backup_note_id]

    if backup_note_id.blank?
      render json: { error: 'Delete backup note fail!' }, status: :bad_request
      return
    end

    backup_note = BackupNote.find_by(id: backup_note_id)

    if backup_note
      backup_note.destroy
      render json: { message: 'Delete backup note success' }, status: :ok
    else
      render json: { error: 'Backup Note not found' }, status: :bad_request
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def backup_note_download
    backup_note_id = params[:backup_note_id]

    if backup_note_id.blank?
      render json: { error: 'Download backup note fail!' }, status: :bad_request
      return
    end

    backup_note = BackupNote.find_by(id: backup_note_id)

    if backup_note.nil?
      render json: { error: 'Download backup note fail!' }, status: :not_found
      return
    end

    # send download as .txt
    send_data backup_note.content, filename: "#{backup_note.id}.txt", type: 'text/plain'
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # Auth actions
  def auth_revoke_session
    session_id = params[:sid]
    user_id = session[:user]["id"]

    if session_id.blank?
      return render json: { error: 'Revoke session fail!' }, status: :bad_request
    end

    UserSessionManager.destroy_session(user_id, session_id)
    reset_session

    render json: { message: 'Revoke session success!' }, status: :ok
  end
rescue StandardError => e
  render json: { error: e.message }, status: :bad_request
end

# User actions
def user_update
  user_id = session[:user]["id"]
  user_update_request = UserUpdateRequest.new(params.permit(:email, :password, :avatar))

  unless user_update_request.valid?
    return render json: { errors: user_update_request.errors.full_messages }, status: :bad_request
  end

  user = User.find_by(id: user_id)
  if user
    user.assign_attributes(
      email: user_update_request.email.presence ? user_update_request.email : user.email,
      avatar: user_update_request.avatar.presence ? user_update_request.avatar.url : user.avatar,
      hash_password: user_update_request.password.presence ? BCrypt::Password.create(user_update_request.password) : user.hash_password
    )
    user.save!

    render json: { message: 'Update account success!' }, status: :ok
  else
    render json: { error: 'User not found' }, status: :not_found
  end
rescue ActiveRecord::RecordInvalid => e
  render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
rescue StandardError => e
  render json: { errors: [e.message] }, status: :bad_request
end
