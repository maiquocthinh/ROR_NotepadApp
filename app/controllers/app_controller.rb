class AppController < ApplicationController

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
    @slug = params[:slug]
    @share_type = params[:share_type]
    @external_slug = params[:external_slug]
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
