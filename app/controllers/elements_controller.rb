class ElementsController < ApplicationController
  def index
    render :file => "layouts/application.html.erb", :layout => false
  end
end
