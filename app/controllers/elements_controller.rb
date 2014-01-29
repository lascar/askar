class ElementsController < ApplicationController
  PERMITED_FIELDS = ["id", "name", "description"]
  DEFAULT_FIELDS = ["id", "name", "description"]
  before_action :field_names_can_be

  def index
    render :file => "layouts/application.html.erb", :layout => false
  end

  def list
    execute
  end

  def show
    execute
  end

  private
    def field_names_can_be
      unless params[:fields] and (PERMITED_FIELDS & params[:fields]).size == params[:fields].size
        params[:fields] = DEFAULT_FIELDS
      end
    end

    def execute
      controller = params[:controller]
      action = params[:action]
      element_name = controller.singularize
      element_model = element_name.camelize.constantize
      fields = params[:fields]
      fields_to_show = DEFAULT_FIELDS - ["id"]
      case action
      when "list"
        element = nil
        elements = element_model.select(fields)
        actions = ["elements/show"]
      when "show"
        element = element_model.find(params[:id])
        elements = nil
        actions = ["elements/show"]
      end
      locals = {controller: controller, action: action,
                fields: fields, fields_to_show: fields_to_show,
                elements: elements, element: element, actions: actions}
      render :json => locals.to_json
    end

end
