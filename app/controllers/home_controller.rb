class HomeController < ApplicationController
  PERMITED_ELEMENTS = ["element"]
  DEFAULT_ELEMENT = "element"
  PERMIDED_FIELDS = ["id", "name", "description"]
  DEFAULT_FIELDS = ["name", "description"]
  before_action :element_name_can_be, :field_names_can_be

  # GET /elements
  # GET /elements.json
  def index

  end

  def list
    fields = params[:fields] || ["id", "name", "description"]
    elements = Element.select(fields)
    actions = ["show"]
    respond_to do |format|
      format.js {render "home/list.js.erb", locals: {fields: fields, elements: elements, actions: actions}, layout: false}
    end
  end

  def show
    element_name = params[:element_name]
    render  "home/show.js.erb" 
  end

  private
    def element_name_can_be
      params[:element_name] = DEFAULT_ELEMENT unless PERMITED_ELEMENTS.include?(params[:element_name])
    end
    
    def field_names_can_be
      unless params[:field_names] and (PERMIDED_FIELDS & params[:field_names]).size == params[:field_names].size
        params[:field_names] = ["name", "description"]
      end
    end

end
