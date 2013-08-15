require 'spec_helper'
describe "elements/list.html.haml", :js => true do
  context "there are 253 elements" do
    before(:each) do
      for i in (1 .. 253) do
        create(:element, :name => "element_" + i.to_s)
      end
      visit elements_list_path(:page => 8)
    end

    it "get elements list with pagination" do
      page.should have_css('.list_element', :count => 20)
    end

    it "get element number 161" do
    end
  end
end
