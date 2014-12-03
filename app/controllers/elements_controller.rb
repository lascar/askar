# displays the layout and responds to ajax
class ElementsController < ApplicationController
  PERMITED_FIELDS = ["id", "name", "description"]
  DEFAULT_FIELDS = ["id", "name", "description"]
  before_action :field_names_can_be

  def index
    render :file => "layouts/application.html.erb", :layout => false
  end

  def list
    (element_name, element_model) = element_name_model
    element = nil
    elements = elements_list(element_model)
    actions = ["elements/show"]
    locals_render(elements, element, actions)
  end

  def show
    (element_name, element_model) = element_name_model
    element = element_show(element_model)
    elements = nil
    actions = ["elements/show"]
    locals_render(elements, element, actions)
  end

  private
    def field_names_can_be
      params_fields = params[:fields]
      unless params_fields && (PERMITED_FIELDS & params_fields).size == params_fields.size
        params[:fields] = DEFAULT_FIELDS
      end
    end

    def elements_list(element_model)
      element_model.select(params[:fields])
    end

    def element_show(element_model)
      element_model.find(params[:id])
    end

    def element_name_model
      element_name = params[:controller].singularize
      [element_name, element_name.camelize.constantize]
    end

    def locals_render(elements, element, actions)
      fields = params[:fields]
      locals = {controller: params[:controller], action: params[:action],
                fields: fields, fields_to_show: fields - ["id"],
                elements: elements, element: element, actions: actions}
      render :json => locals.to_json
    end

end
