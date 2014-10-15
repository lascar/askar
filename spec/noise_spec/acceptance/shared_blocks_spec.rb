require 'spec_helper'

feature "Shared blocks" do

  background do
    login_as('user', 'editor')

    @block = create_valid_shared_block(name: "Advertising")

    visit root_path
    click_link "Edit Shared Blocks"
  end

  scenario "Creating a new Story headlines block" do
    click_link "New headlines block"

    fill_in "Name", with: "Blogroll"
    click_button "Save"

    page.should have_css(".alert-info", text: "Block was successfully created")

    page.should have_css(".block", text: "Blogroll")
  end

  scenario "Creating a new Standalone headlines block" do
    click_link "New headlines block"

    fill_in "Name", with: "Buttons"
    select "Buttons", from: "Style Hint"
    click_button "Save"

    page.should have_css(".alert-info", text: "Block was successfully created")
    page.should have_css(".block", text: "Buttons")
  end

  scenario "Creating a new HTML code block" do
    click_link "New html block"

    fill_in "Name", with: "Advertising"
    click_button "Save"

    page.should have_css(".alert-info", text: "Block was successfully created")
    page.should have_css(".block", text: "Advertising")
  end

  scenario "Changing the title" do

    find('.block a', text:'Advertising').click
    click_link 'Edit'

    fill_in 'Name', with: 'Marekting'
    click_button 'Save'

    page.should have_content("Marekting")
    page.should have_content("Marekting: (unlimited standalone headlines)")
  end

  scenario "Deleting" do
    page.should have_css(".block", count: 1)

    click_button 'Delete'

    page.should_not have_css(".block")
  end

  context "Publishing" do

    scenario "suspended block" do
      @block.suspend!

      # This should not be needed but publish/preview is called
      # everytime a block is save (including on creation)
      @base_path = File.dirname(Publisher.publish_path(@block))
      FileUtils.rmtree(@base_path)

      visit block_path(@block)

      click_button "Publish"
      page.should have_css(".alert-info", text: "Block was successfully published")

      published_files = Dir.glob("#{@base_path}/data.json").map {|f| File.basename(f)}
      published_files.should == ["data.json"]
    end

    scenario "active block" do
      @block.resume!

      # This should not be needed but publish/preview is called
      # everytime a block is save (including on creation)
      @base_path = File.dirname(Publisher.publish_path(@block))
      FileUtils.rmtree(@base_path)

      visit block_path(@block)
      click_button "Publish"

      page.should have_css(".alert-info", text: "Block was successfully published")

      @base_path = File.dirname(Publisher.publish_path(@block))
      published_files = Dir.glob("#{@base_path}/data.json").map {|f| File.basename(f)}
      published_files.should == ["data.json"]
    end

  end

end
