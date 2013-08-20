require 'spec_helper'
describe 'user log via ajax', :js => true do
  before(:each) do
    create(:user)
    create(:element)
    visit elements_list_path
  end
 
  context 'when the user is not authenticated' do
    it 'display an empty list of element' do
      visit root_path
      expect(page).to have_css('#elements')
      expect(page.all('.list_element').size).to eq(0)
    end
  # save_page('capy.page.html')
  # :focus => true
  end
end

