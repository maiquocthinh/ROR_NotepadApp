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
