require 'spec_helper'
describe 'list add element' do
  before(:all) do
    @element = Element.create(:name => 'element 1')
  end

  it 'lets the user add an new element', :js => true do
    visit elements_list_path
    click_on "New Element"
    fill_in 'Name', :with => 'element 2'
    fill_in 'Short description', :with => 'brief description'
    click_button('Create Element')
    find('#element_2_name', :visible => true).text.should == "element 2"
    save_page('capy.page.html')

  end
end
describe 'list show element' do
  it 'lets the user add an new element', :js => true do
    visit elements_list_path
    find(:xpath, '//a[@href="/elements/show/1"]').text.should == "Show"
    find(:xpath, '//a[@href="/elements/show/1"]').click
    find('#element_1_show_name', :visible => true).text.should == "element 2"
    save_page('capy.page.html')
  end
end
