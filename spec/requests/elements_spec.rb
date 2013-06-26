require 'spec_helper'
describe 'list add element' do
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

  # :focus => true
  it 'lets the user add an new element', :js => true do
    visit elements_list_path
    save_page('capy.page.html')
    find(:xpath, '//a[@href="/elements/show/1"]').text.should == "Show"
    find(:xpath, '//a[@href="/elements/show/1"]').click
    find('#element_1_show_name', :visible => true).text.should == "element 1"
  end
end
