require 'spec_helper'

describe "elements/list.html.haml" do
  context "there are 253 elements" do
    for i in (1 .. 253) do
      puts "i : " + i.to_s
      let!(('element_' + i.to_s).to_sym){FactoryGirl.create(:element, :name => "element_" + i.to_s)}
      #Element.create(:name => 'element_' +  i.to_s)
    end

    before(:each) do
      visit '/elements/list?page=8' 
    end

    it "get elements list with pagination" do
      visit '/elements/list?page=8' 
      page.should have_css('.element_list', :count => 20)
    end

    it "get elements list with offset de page" do
      save_page('capy.html')
      page.should have_css('#element_141')
      page.should have_css('#element_160')
    end
    
    it "is some way to go one page back" do
      within('#tab_content_elements_list') do
        find('a.link_page_back')['href'] == '/elements/list?page=7'
      end
    end

    it "is some way to go one page further" do
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

