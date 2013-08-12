require 'spec_helper'

describe "elements/list.html.haml" do
  context "there are 53 elements" do
    before(:each) do
      for i in (1 .. 53) do
        create(:element, :name => "element_" + i.to_s)
      end
      elements = Element.all
      element = Element.new
    end

    it "get elements list with pagination" do
      visit '/elements/list'
      page.should have_css('.list_element', :count => 20)
    end

    it "get elements list with offset de page" do
      visit '/elements/list?page=2'
      save_page('capy.page.html')
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

    context "there is a total element count and max per page" do
      before(:each) do
        count = 53
        max_per_page = 20
        visit '/elements/list'
      end
      
      it "is warned in witch page we are" do
        #save_page('capy.page.html')
        within('#footer_elements_list') do
          within('.paginate') do
            find('span#actual_page').text == '1'
          end
        end
        visit '/elements/list?page=2'
        within('#footer_elements_list') do
          within('.paginate') do
            find('span#actual_page').text == '2'
          end
        end
      end
      
      it "is warned how much elements are in total" do
        total_elements = Element.count
        within('#footer_elements_list') do
          within('.paginate') do
            find('span#total_pages').text == (total_elements / 20 + 1).ceil.to_s
          end
        end
      end
    end
  end
end

