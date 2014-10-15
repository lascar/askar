  shared_examples_for "a correct header that indicates when it's empty" do
    scenario 'empty and after full with a headlines block' do
      match_empty = select_assert('.panel-header h3', regexs)
      match_empty.should == 1
      click_link 'Add headlines block'
      fill_in 'Name', with: 'Royalty fashion news'

      click_button 'Save'

      match_empty = select_assert('.panel-header h3', regexs)
      match_empty.should == 0
    end
  end
