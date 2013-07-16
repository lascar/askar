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

    it "get elements list with pagination" do
      visit '/elements/list'
      page.should have_css('.list_element', :count => 20)
    end

    it "get elements list with offset de page" do
      visit '/elements/list?page=2'
      page.save_screenshot('screenshot.png')
      page.should have_css('#element_21')
    end
    
    it "is some way to go one page back" do
      visit '/elements/list?page=2'
      within('#tab_content_elements_list') do
        find('a.link_page_back')['href'] == '/elements/list?page=1'
      end
    end

    it "is some way to go one page futher" do
      visit '/elements/list?page=2'
      within('#tab_content_elements_list') do
        find('a.link_page_forward')['href'] == '/elements/list?page=3'
      end
    end

  end
end

