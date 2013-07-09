require 'spec_helper'

describe "elements/list.html.haml" do
  context "there are 53 elements" do
    before(:each) do
      for i in (1 .. 53) do
        create(:element, :name => "element_" + i.to_s)
      end
      @elements = Element.all
      @element = Element.new
    end

    it "get the elements list with pagination", :focus => true do
      visit '/elements/list'
      page.should have_css('.list_element', :count => 53)
    end
  end
end

