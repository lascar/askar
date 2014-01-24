class ElementsController < ApplicationController
  def index
    render :file => "layouts/application.html.erb", :layout => false
  end
  
  def list
    render :json => Element.all.to_json
  end
  
  def update
    console.log(params)
  end
end
