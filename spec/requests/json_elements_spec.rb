require 'spec_helper'
describe 'comunication with server only through json' do
  context 'when 1 element and list tab ready' do
    before(:each) do
      create(:element)
      visit elements_list_path
    end

    it 'list must have tab for content without display ready' do
      page.should have_selector('#tab_elements_show')
      within('#tab_elements_show.template') do
      end
    end

  end
end
   
