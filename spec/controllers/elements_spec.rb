require 'spec_helper'
# as the controller's variables are pass as local
# we do not test them
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

    end
  end
end
