require 'spec_helper'

describe "elements/list.html.haml" do
  context "there are 253 elements" do
    before(:each) do
      for i in (1 .. 253) do
        create(:element, :name => "element_" + i.to_s)
      end
      visit '/elements/list?page=8'
    end

    it "get elements list with pagination" do
      page.should have_css('.list_element', :count => 20)
    end

    it "get elements list with offset de page" do
      save_page('capy.html')
      page.should have_css('#element_81')
    end
    
    it "is some way to go one page back" do
      within('#tab_content_elements_list') do
        find('a.link_page_back')['href'] == '/elements/list?page=7'
      end
    end

    it "is some way to go one page further" do
      visit '/elements/list?page=2'
      within('#tab_content_elements_list') do
        find('a.link_page_forward')['href'] == '/elements/list?page=9'
      end
    end

    it "is warned in witch page we are" do
      #save_page('capy.page.html')
      within('#footer_elements_list') do
        within('.paginate') do
          find('span#actual_page').text == '8'
        end
      end
    end
    
    it "is warned how much pages are in total" do
      total_pages = (Element.count / 20).ceil + 1
      within('#footer_elements_list') do
        within('.paginate') do
          find('span#total_pages').text == total_pages.to_s
        end
      end
    end
  end
end

