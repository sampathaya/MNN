class PagesController < InheritedResources::Base

  def show
    @page = Page.find(params[:id])
    no_cache_headers
    headers['Last-Modified'] = @page.updated_at.httpdate if @page
    respond_to do |format|
      format.html
      format.json { render json: @page }
      format.js { render layout: false }
    end
  end

  def index
    @pages = Page.active
  end

  def edit
    redirect_to root_path
  end

  def new
    redirect_to root_path
  end

end
