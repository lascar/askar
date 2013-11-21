class HomeController < ApplicationController
  PERMITED_ELEMENTS = ["element"]
  DEFAULT_ELEMENT = "element"
  PERMITED_FIELDS = ["id", "name", "description"]
  DEFAULT_FIELDS = ["id", "name", "description"]
  before_action :element_name_can_be, :field_names_can_be

  def index
    render :index
  end

  def list
    fields = params[:fields]
    fields_to_show = DEFAULT_FIELDS - ["id"]
    element_name = params[:element_name]
    element_model = element_name.camelize.constantize
    elements = element_model.select(fields)
    actions = ["show"]
    render "home/list.js.erb", locals: {fields: fields, fields_to_show: fields_to_show, element_name: element_name, elements: elements, actions: actions}
  end

  def show
    fields = params[:fields] || DEFAULT_FIELDS
    fields_to_show = DEFAULT_FIELDS - ["id"]
    element_name = params[:element_name]
    element_model = element_name.camelize.constantize
    element = element_model.select(fields).find(params[:id])
    render  "home/show.js.erb", locals: {fields: fields, fields_to_show: fields_to_show, element_name: element_name, element: element}
  end

  private
    def element_name_can_be
      params[:element_name] = DEFAULT_ELEMENT unless PERMITED_ELEMENTS.include?(params[:element_name])
    end
    
    def field_names_can_be
      unless params[:fields] and (PERMITED_FIELDS & params[:fields]).size == params[:fields].size
        params[:fields] = DEFAULT_FIELDS
      end
    end

end
