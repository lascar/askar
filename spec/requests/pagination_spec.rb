require 'spec_helper'
describe "elements/list.html.haml" do
  context "there are 53 elements" do
    before(:each) do
      for i in (1 .. 53) do
        create(:element, :name => "element_" + i.to_s)
      end
      visit elements_list_path
    end

    it "get elements list with pagination", :js => true do
      visit '/elements/list'
      page.should have_css('.list_element', :count => 20)
    end
  end

  it 'do nothing' do
    book = double("book")
    book.stub(:title) { "The RSpec Book" }
  end
end
