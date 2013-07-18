require 'spec_helper'
describe ElementsController do
  describe "GET #list" do
    context "there is 1 element" do
      before(:each) do
        create(:element, :name => 'toto')
        get :list
      end

      it "responds successfully with an HTTP 200 status code" do
        expect(response).to be_success
        expect(response.status).to eq(200)
      end

      it "renders the list template" do
        expect(response).to render_template("list")
      end

      it "paginate the @elements" do
        assigns(:elements).count.should be_equal 1
      end
    end

    context "there are 53 elements" do
      before(:each) do
        for i in (1 .. 53) do
          create(:element, :name => "element_" + i.to_s)
        end
        get :list
      end

      it "has 53 elements" do
        assigns(:elements).count.should be_equal 20
      end

      it "has a total element, page, and array of pages to link in list" do
        assigns(:total).should eq 53
        assigns(:page).should eq 1
        assigns(:pages_links).should eq( [1,2,3,4,5] )
      end
    end
  end
end
