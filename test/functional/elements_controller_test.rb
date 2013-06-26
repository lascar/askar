require 'test_helper'

class ElementsControllerTest < ActionController::TestCase
  setup do
    @element = elements(:one)
  end

  test "should get list" do
    get :list
    assert_response :success
    assert_not_nil assigns(:elements)
  end

end
