class ElementsController < ApplicationController
  # GET /elements
  # GET /elements.json
  def list
    @total = Element.count
    @page = params[:page] || 1
    @pages_links = arrays_pages_links
    @elements = Element.offset(params[:page] ? (params[:page].to_i - 1) * 20 : 0).limit(20)
    @element = Element.new

    respond_to do |format|
      format.html { render 'elements/list' }
      format.json { render json: @elements }
    end
  end

  def show
    element = Element.find(params[:id])
    respond_to do |format|
      format.js { render 'elements/show', :locals => {:element => element}}
    end
  end

  def edit
    element = Element.find(params[:id])
    respond_to do |format|
      format.js { render 'elements/edit', :locals => {:element => element}}
    end
  end

  def update
    if params[:id] == "0"
      element = Element.create(:name => params[:element][:name], :short_description => params[:element][:short_description])
    else
      element = Element.find(params[:id])
      element.update_attributes!(element_params)
    end
    respond_to do |format|
      format.js { render 'elements/update', :locals => {:element => element}} 
    end
  end
  
  def delete
    element = Element.find(params[:id]).destroy
    respond_to do |format|
      format.js { render 'elements/delete', :locals => {:element => element}} 
    end
  end

  private
    def element_params
      params.require(:element).permit(:name, :short_description)
    end

    def arrays_pages_links
      case
      when @page < 6
        [1,2,3,4,5]
      end
    end
end
