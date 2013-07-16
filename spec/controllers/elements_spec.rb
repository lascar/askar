require 'spec_helper'
describe ElementsController do
  describe "GET #list" do
    context "there is 1 element" do
      before(:each) do
        create(:element, :name => 'toto')
      end

      it "responds successfully with an HTTP 200 status code" do
        get :list
        expect(response).to be_success
        expect(response.status).to eq(200)
      end

      it "renders the list template" do
        get :list
        expect(response).to render_template("list")
      end

      it "paginate the @elements" do
        get :list
        assigns(:elements).count.should be_equal 1
      end
    end

    context "there are 53 elements" do
      before(:each) do
        for i in (1 .. 53) do
          create(:element, :name => "element_" + i.to_s)
        end
      end

      it "has 53 elements" do
        get :list
        assigns(:elements).count.should be_equal 20
      end
    end
  end
end
