class AppController < ApplicationController
  include AccessChecker

  before_action :check_note_password_requirement, only: [:note_write]
  before_action :check_note_access, only: [:note_login]

  def note_write
    slug = params[:slug]
    note = Note.find_by_slug(slug)
    unless note
      note = Note.create(slug: slug)
      redirect_to "/#{note.slug}"
    end

    @note = note
  end

  def note_login
    slug = params[:slug]
    external_slug = params[:external_slug]
    share_type = params[:share_type]

    if slug.present?
      note = Note.find_by_slug(slug)
      if note.nil?
        return redirect_to "/#{slug}"
      end

      render :note_login, locals: { slug: slug }
    else
      note = Note.find_by_external_slug(external_slug)
      if note.nil?
        return redirect_to "/#{external_slug}"
      end

      render :note_login, locals: { external_slug: external_slug, share_type: share_type }
    end
  end

  def note_share
    external_slug = params[:external_slug]
    note = Note.find_by_external_slug(external_slug)
    unless note
      render_not_found
      return
    end

    @note = note
  end

  def note_raw
    external_slug = params[:external_slug]
    note = Note.find_by_external_slug(external_slug)

    unless note
      render_not_found
      return
    end

    render plain: note.content || ""
  end

  def note_code
    external_slug = params[:external_slug]
    note = Note.find_by_external_slug(external_slug)

    unless note
      render_not_found
      return
    end

    @note = note
  end

  def note_markdown
    external_slug = params[:external_slug]
    note = Note.find_by_external_slug(external_slug)

    unless note
      render_not_found
      return
    end

    render layout: 'markdown', locals: { content: note.content }
  end

  def note_backup
  end

  def not_found
    render status: :not_found
  end

  private

  def render_not_found
    render template: 'errors/404', status: :not_found
  end

end
