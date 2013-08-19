require 'spec_helper'
describe 'user log via ajax', :js => true do
  before(:each) do
    create(:user)
    visit elements_list_path
  end
 
  context 'the user is not authenticated' do
    it 'lauch a modal for login' do
    end

  # save_page('capy.page.html')
  # :focus => true
  end
end

