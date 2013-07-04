class ElementsController < ApplicationController
  # GET /elements
  # GET /elements.json
  def list
    @elements = Element.all
    @element = Element.new

    respond_to do |format|
      format.html # list.html.erb
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
      element.update_attributes(params[:element])
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
end
