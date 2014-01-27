class ElementsController < ApplicationController
  def index
    render :file => "layouts/application.html.erb", :layout => false
  end
  
  def list
    render :json => Element.all.to_json
  end
  
  def update
    element = Element.find(params[:id])
    element.update!(element_params)
    render :nothing => true
  end
  
  private
    def element_params
      params.require(:element).permit(:name, :description)
    end
end
