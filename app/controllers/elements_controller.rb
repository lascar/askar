class ElementsController < ApplicationController
  PERMITED_FIELDS = ["id", "name", "description"]
  DEFAULT_FIELDS = ["id", "name", "description"]
  before_action :field_names_can_be

  def index
    #render :index
    render :file => "layouts/application.html.haml", :layout => false
  end

  def list
    fields = params[:fields]
    fields_to_show = DEFAULT_FIELDS - ["id"]
    element_name = params[:controller].singularize
    element_model = element_name.camelize.constantize
    elements = element_model.select(fields)
    controller = params[:controller]
    action = params[:action]
    actions = ["show"]
    locals = {controller: controller, action: action,
              fields: fields, fields_to_show: fields_to_show,
              elements: elements, actions: actions}
    render :json => locals.to_json
  end

  def show
    fields = params[:fields] || DEFAULT_FIELDS
    fields_to_show = fields
    element_name = params[:controller].singularize
    element_model = element_name.camelize.constantize
    element = element_model.select(fields).find(params[:id])
    controller = params[:controller]
    action = params[:action]
    actions = ["show"]
    locals = {controller: controller, action: action,
              fields: fields, fields_to_show: fields_to_show,
              element: element, actions: actions}
    render :json => locals.to_json
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
