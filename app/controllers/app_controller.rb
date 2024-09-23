  class AppController < ApplicationController
  def index
    redirect_to write_page_path IdGenerator.generate_slug
  end

  def note_write
    @slug = params[:slug]
  end

  def note_login
    @slug = params[:slug]
    @share_type = params[:share_type]
    @external_slug = params[:external_slug]
  end

  def note_share

  end

  def note_raw
    render plain: params[:external_slug]
  end

  def note_code

  end

  def note_markdown

  end

  def note_backup

  end

  def not_found
    render status: :not_found
  end
end
