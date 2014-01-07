class ElementsController < ApplicationController
  respond_to :json
  PERMITED_FIELDS = ["id", "name", "description"]
  DEFAULT_FIELDS = ["id", "name", "description"]
  before_action :set_element, only: [:show, :edit, :update, :destroy]
  before_action :field_names_can_be

  # GET /elements
  def index
    respond_with(@elements = Element.all)
  end

  # GET /elements/1
  def show
    respond_with(@element = Element.find(params[:id]))
  end

  # GET /elements/new
  def new
    respond_with(@element = Element.new)
  end

  # GET /elements/1/edit
  def edit
  end

  # POST /elements
  def create
    @element = Element.new(element_params)

    if @element.save
      redirect_to @element, notice: 'Element was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /elements/1
  def update
    if @element.update(element_params)
      redirect_to @element, notice: 'Element was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /elements/1
  def destroy
    @element.destroy
    redirect_to elements_url, notice: 'Element was successfully destroyed.'
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_element
      @element = Element.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def element_params
      params.require(:element).permit(:name, :description)
    end

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
        actions = ["elements_show"]
      when "show"
        element = element_model.find(params[:id])
        elements = nil
        actions = ["elements_show"]
      end
      locals = {controller: controller, action: action,
                fields: fields, fields_to_show: fields_to_show,
                elements: elements, element: element, actions: actions}
      render :json => locals.to_json
    end

end
