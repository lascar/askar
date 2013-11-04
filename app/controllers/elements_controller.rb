class ElementsController < ApplicationController
  before_action :set_element, only: [:show, :edit, :update, :destroy]

  # GET /elements
  # GET /elements.json
  def index

  end

  def list
    fields = ["id", "name", "description"]
    elements = Element.select(fields)

    respond_to do |format|
      format.js {render "elements/list.js.erb", locals: {fields: fields, elements:  elements}, layout: false}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_element
      @element = Element.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def element_params
      params.require(:element).permit(:name, :description)
    end
end
