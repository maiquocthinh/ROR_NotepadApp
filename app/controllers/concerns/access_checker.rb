module AccessChecker
  extend ActiveSupport::Concern

  def check_panel_login

    if session[:user]
      if ["login", "register", "forgot_password", "reset_password"].include?(action_name)
        return redirect_to panel_path
      end
    else
      if action_name == "index"
        return redirect_to panel_login_path
      end
    end

  end

  def check_note_password_requirement
    slug = params[:slug]
    external_slug = params[:external_slug]
    notes_logged_in = session[:notes_logged_in] || []

    if slug.present?
      # get note from db
      note = Note.select(:need_password).find_by(slug: slug)

      # if note don't need password, go to note
      return if !note || !note.need_password?

      # if note no logged in, redirect to login page
      redirect_to "/login/#{slug}" unless notes_logged_in.include?(slug)
    elsif external_slug.present?
      share_type = request.path.match(%r{/([^/]+)/})[1] rescue nil

      # get note from db
      note = Note.select(:slug, :need_password).find_by(external_slug: external_slug)

      # if note don't need password, go to note
      return if note&.need_password.nil?

      # if note no logged in, redirect to login page
      redirect_to "/login/#{share_type}/#{external_slug}" unless notes_logged_in.include?(note.slug)
    end
  end

  def check_note_access
    slug = params[:slug]
    external_slug = params[:external_slug]
    share_type = params[:share_type]
    notes_logged_in = session[:notes_logged_in] || []

    if slug
      # if note logged in, redirect to note (skip login)
      return redirect_to "/#{slug}" if notes_logged_in.include?(slug)

      # get note from db
      note = Note.find_by_slug (slug)

      # if note not exists, redirect to create new note
      return redirect_to "/#{slug}" unless note

      # if note don't need password, redirect to note
      return redirect_to "/#{slug}" unless note.need_password
    elsif external_slug
      # get note from db
      note = Note.find_by_external_slug(external_slug)

      # if note not exists, redirect to create new note
      return redirect_to "/#{slug}" unless note

      # if note logged in, redirect to note(share link) (skip login)
      return redirect_to "/#{share_type}/#{external_slug}" if notes_logged_in.include?(note.slug)

      # if note don't need password, redirect to note(share link)
      return redirect_to "/#{share_type}/#{external_slug}" unless note.need_password
    end
  end

end
