class ElementsController < ApplicationController
  respond_to :json
  PERMITED_FIELDS = ["id", "name", "description"]
  DEFAULT_FIELDS = ["id", "name", "description"]
  before_action :field_names_can_be

  def index
    per_page = params[:per_page] || Rails.application.config.per_page
    page = params[:page] || 1
    offset = per_page * (page - 1)
    response = {
      :serie_name => "elements",
      :object_name => "element",
      :object_attributes => DEFAULT_FIELDS,
      :actions => ["show", {:edit => ["update"]}],
      :page => page,
      :per_page => per_page,
      :total_page => Element.count / per_page,
      :offset => offset,
      :values => Element.offset(offset).limit(per_page)
    }
    respond_with(response)    
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

  #ex. receive {serie_name: "elements", object_name: "element", object_attributes: ["name", "description", "weight"], actions: ["show", {edit: ["update"]}], values: [{id: 1, name: "element 1", description: "first element", weight: 25}, {id: 2, name: "element 2", description: "second element", weight: 34}], attributes_show_series: ["name", "descripcion"], attributes_show_object: ["id", "name", "description", "weight"], page: 2, total_pages: 4, per_page: 10}
    def execute
      controller = params[:controller]
      action = params[:action]
      element_name = controller.singularize
      element_model = element_name.camelize.constantize
      fields = params[:fields]
      fields_to_show = DEFAULT_FIELDS - ["id"]
      case action
      when "list"
        serie_name = "elements"
        object_name = "element"
        object_attributes = DEFAULT_FIELDS
        actions = ["show", {:edit => ["update"]}]
        page = params[:page] || 1
        per_page = params[:per_page] || Rails.application.config.per_page
        offset = per_page * (page - 1)
        values = Element.offset(offset).limit(per_page)
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
