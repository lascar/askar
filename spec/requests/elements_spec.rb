require 'spec_helper'
describe 'add, show, update and delete element' do
  before(:each) do
    Element.create!(:name => 'element 1')
  end

  it 'lets the user add an new element', :js => true do
    visit elements_list_path
    click_on "New Element"
    fill_in 'Name', :with => 'element 2'
    fill_in 'Short description', :with => 'brief description'
    click_button('Create Element')
    find('#element_2_name', :visible => true).text.should == "element 2"
  end

  # save_page('capy.page.html')
  # :focus => true
  it 'lets the user show an new element', :js => true do
    visit elements_list_path
    find(:xpath, '//a[@href="/elements/show/1"]').text.should == "Show"
    find(:xpath, '//a[@href="/elements/show/1"]').click
    find('#element_1_show_name', :visible => true).text.should == "element 1"
  end
  
  it 'lets the user update an new element from index', :js => true do
    visit elements_list_path
    find(:xpath, '//a[@href="/elements/edit/1"]').text.should == "Edit"
    find(:xpath, '//a[@href="/elements/edit/1"]').click
    find(:xpath, '//textarea[@id="element_short_description"]')
    fill_in "element[short_description]", :with => 'primero elemento'
    click_button('Update Element')
    find('#element_1_short_description', :visible => true).text.should == "primero elemento"
  end
  
  it 'lets the user update an new element from show', :focus => true, :js => true do
    visit elements_list_path
    find(:xpath, '//a[@href="/elements/show/1"]').click
    find(:xpath, '//a[@id="element_1_show_edit_link"]').click
    find('#element_short_description')
    fill_in "element[short_description]", :with => 'primero elemento'
    click_button('Update Element')
    find('#element_1_show_short_description', :visible => true).text.should == "primero elemento"
    find('#tab_elements_list').click
    find('#element_1_short_description', :visible => false ).text.should == 'primero elemento'
  end
end
