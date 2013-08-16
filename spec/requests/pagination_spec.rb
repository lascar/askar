require 'spec_helper'
describe "elements/list.html.haml" do
  context "there are 253 elements", :js => true do
    for i in (1 .. 253) do
      puts "i : " + i.to_s
      let!(('element_' + i.to_s).to_sym){FactoryGirl.create(:element, :name => "element_" + i.to_s)}
      #Element.create(:name => 'element_' +  i.to_s)
    end

    before(:each) do
      visit '/elements/list?page=8' 
    end

    it "get elements list with pagination" do
      expect(page).to have_css('.list_element', :count => 20)
    end

  end
end
