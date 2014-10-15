require "spec_helper"

feature "Pages" do

  before(:each) do
    login_as('user', 'editor')
  end

  scenario "Searching Tags (with and without associated page)" do
    create_valid_page(title: 'Cinema')
    create_valid_tag(name: "Mary Doe")
    tag = create_valid_tag(name: "John Doe")
    tag_page = tag.create_associated_page

    visit root_path
    click_link "Pages"

    fill_in "Search for", with: "John"
    click_button "Search"

    within "#tag-search-results" do
      page.should have_content "John Doe"
      page.should_not have_content "Mary Doe"
      page.should_not have_content "Cinema"
    end

    fill_in "Search for", with: "Doe"
    click_button "Search"

    within  "#tag-search-results" do
      page.should have_content "John Doe"
      page.should have_content "Mary Doe"
      page.should_not have_content "Cinema"
    end
  end

  scenario "Creating a page" do
    visit root_path

    click_link "Pages"
    click_link "New Special"

    fill_in "Category", with: "Royalty"
    fill_in "Title", with: "Royalty"

    select "Category Page", from: "Page template"

    click_button "Save"

    page.should have_css('h3', text: "Royalty")

  end

  context "Managing areas" do

    background do
      template = Template.find_by_name('Category Page')

      create_valid_shared_area(name: "Main News area")
      create_valid_shared_area(name: "Sidebar")

      @page = create_valid_page(title: 'Royalty', template_id: template.id)

      @page.regions << create_valid_region(name: 'News Region')
      @page.regions << create_valid_region(name: 'Sidebar Region')
    end

    scenario "Adding an area to a page region" do
      visit pages_path
      click_link "Royalty"

      click_link "News Region"
      click_link "Add Area"

      fill_in "Area name", with: "Some area"
      click_button "Create Area"
      page.should have_css('.area h3', text: "Area: Some area")

    end

    scenario "Deleting an area from a page region" do

      visit pages_path
      click_link "Royalty"

      click_link "News Region"
      click_link "Add Area"

      fill_in "Area name", with: "Some area"
      click_button "Create Area"
      page.should have_css('.area h3', text: "Area: Some area")

      click_button("Delete")

      page.should_not have_css('.area h3', text: "Area: ")
    end

    scenario "Linking a shared area to a page region" do
      visit pages_path
      click_link "Royalty"

      click_link "News Region"

      click_link "Add Area"
      select "Main News area",  from: "Choose A Shared Area"
      click_button "Link to shared area"
      page.should have_css('.area h3', text: "Shared area: Main News area")

      click_link "Sidebar Region"
      click_link "Add Area"
      select "Sidebar",  from: "Choose A Shared Area"
      click_button "Link to shared area"

      page.should_not have_css('.area h3', text: "Shared area: Main News area")
      page.should have_css('.area h3', text: "Shared area: Sidebar")
    end

    scenario "Unlinking a shared area from a page region" do
      visit pages_path
      click_link "Royalty"

      click_link "News Region"
      click_link "Add Area"
      select "Main News area",  from: "Choose A Shared Area"
      click_button "Link to shared area"

      page.should have_css('.area h3', text: "Shared area: Main News area")

      click_button "Unlink"

      page.should_not have_css('.area h3', text: "Shared area: Main News area")
    end
  end

  context "Publishing" do

    before(:each) do
      @category = create_valid_category

      @area = create_valid_area

      @block = create_valid_block
      @area.blocks << @block

      @page = @category.page
      @page.regions.first.areas << @area

      visit page_path(@page)
      click_link "Publish"

      page.should have_css('.alert-info', text: "Page was successfully published")

      @base_path = File.dirname(Publisher.publish_path(@page))
      @block_path = File.dirname(Publisher.publish_path(@block))
    end

    scenario "Blocks inside a page are published independently" do
      published_blocks = Dir.glob("#{@block_path}/*").map {|f| File.basename(f)}
      published_blocks.should == ["data.json"]
    end

    scenario "Successful publishing a page without images creates data file" do
      published_files = Dir.glob("#{@base_path}/data.json").map {|f| File.basename(f)}
      published_images = Dir.glob("#{@base_path}/*.jpg").map {|f| File.basename(f)}
      published_files.should == ["data.json"]
      published_images.should be_empty
    end

    scenario "Successful publishing a page without images writes json representation of page" do
      data_file_content = File.open("#{@base_path}/data.json", "rb").read
      data_file_content.should == @page.as_json.to_json
    end
  end

  context "Previewing" do

    before(:each) do
      @category = create_valid_category

      @area = create_valid_area

      @block = create_valid_block
      @area.blocks << @block

      @page = @category.page
      @page.regions.first.areas << @area
      login_as('user', 'admin')
      visit preview_page_path(@page)

      prefix = Publisher.first_preview_path
      @base_path = File.dirname(Publisher.publish_path(@page, prefix))
      @block_path = File.dirname(Publisher.publish_path(@block, prefix))
    end

    scenario "Blocks inside a page are previewing independently" do
      published_blocks = Dir.glob("#{@block_path}/*").map {|f| File.basename(f)}
      published_blocks.should == ["data.json"]
    end

    scenario "Successful previewing a page without images creates data file" do
      published_files = Dir.glob("#{@base_path}/data.json").map {|f| File.basename(f)}
      published_images = Dir.glob("#{@base_path}/*.jpg").map {|f| File.basename(f)}
      published_files.should == ["data.json"]
      published_images.should be_empty
    end

    scenario "Successful previewing a page without images writes json representation of page" do
      data_file_content = File.open("#{@base_path}/data.json", "rb").read
      data_file_content.should == @page.as_json.to_json
    end
  end

  context "SEO" do

    background do
      template = Template.find_by_name('Category Page')
      template.regions << create_valid_region(name: 'News Region')
      template.regions << create_valid_region(name: 'Sidebar Region')

      create_valid_shared_area(name: "Main News area")
      create_valid_shared_area(name: "Sidebar")

      @page = create_valid_page(title: 'Royalty', template_id: template.id)
      login_as('user', 'seo')
    end

    scenario "SEO role only sees SEO tab" do
      visit root_path
      click_link 'Pages'
      click_link 'Royalty'

      page.should_not have_css('.nav.nav-tabs a', text: 'Page')
      page.should have_css('.nav.nav-tabs a', text: 'SEO')
    end

    scenario "Editor role can also see SEO tab" do
      login_as('user', 'editor')

      visit root_path
      click_link 'Pages'
      click_link 'Royalty'

      page.should have_css('.nav.nav-tabs a', text: 'Page')
      page.should have_css('.nav.nav-tabs a', text: 'SEO')
    end


    scenario "Inheriting Title and Base url from page" do
      @page.update_attributes(title: "New page title")

      visit root_path
      click_link 'Pages'
      click_link @page.pageable.name
      click_link 'SEO'

      page.should have_field "Meta title", with: "New page title"
      page.should have_field "Meta description"
      page.should have_field "Meta keywords"
      page.should have_field "Base url", with: @page.slug
      page.should have_field "Redirection"
      page.should have_field "Canonical"
    end

    scenario "Editing SEO fields" do
      visit root_path
      click_link 'Pages'
      click_link 'Royalty'

      click_link "SEO"

      within "#seo-tab" do
        fill_in "Meta title",   with: "The Queen Mother"
        fill_in "Meta description",   with: "The Queen Mother rises from the grave"
        fill_in "Meta keywords",   with: "UK, Queen Mother, Royal, London"

        fill_in "Base url",   with: "http://hola.com"
        fill_in "Redirection",   with: "http://hola.com"
        fill_in "Canonical",   with: "http://www.hola.com/tags/hombre/el-look-de/"

        click_button "Save"
      end

      page.should have_css('.alert-info', text: "Page was successfully updated")
    end

  end

  context "Category data (role: editor)" do

    scenario "Document Type" do
      @category = create_valid_category(name: "Magazines", document_type: nil)
      visit page_path(@category.page)
      click_link "Edit category data"

      within "#category-tab" do
        page.should have_select("Document Type")
        select "Magazine", from: "Document Type"
        click_button "Save"
      end
      page.should have_css('.alert-info', text: "Page was successfully updated")

      visit page_path(@category.page)
      click_link "Edit category data"

      within "#category-tab" do
        page.should have_select("Document Type", selected: "Magazine")
      end
    end

  end

  context "Advertising" do
    scenario "Publicity for a Category Page" do
      @page = create_valid_page(title: 'Royalty')
      login_as('user', 'editor')

      visit page_path(@page)
      click_link "Advertising"

      within "#publicity-tab" do

        page.should have_select('Publicity Formats', selected: ["Mid-Page Unit (300x250)", "Leaderboard (990x90)"])
        select "DHTML (1x1)", from: "Publicity Formats"
        select "Footer (980x450)", from: "Publicity Formats"

        fill_in "Adunit", with: "FortyTwo"
        fill_in "Story Adunit", with: "Seven"
        fill_in "Gallery Adunit", with: "One"

        click_button "Save"

      end

      page.should have_css('.alert-info', text: "Page was successfully updated")

      click_link "Advertising"
      within "#publicity-tab" do

        page.should have_select('Publicity Formats', selected: ["Mid-Page Unit (300x250)", "Leaderboard (990x90)", "DHTML (1x1)", "Footer (980x450)"])

        page.should have_field "Adunit", with: "FortyTwo"
        page.should have_field "Story Adunit", with: "Seven"
        page.should have_field "Gallery Adunit", with: "One"
      end
    end

    scenario "Publicity for a Tag Page" do
      tag = create_valid_tag(name: "John Doe")
      tag_page = tag.create_associated_page

      login_as('user', 'editor')

      visit page_path(tag_page)
      click_link "Advertising"

      within "#publicity-tab" do

        page.should have_select('Publicity Formats', selected: ["Mid-Page Unit (300x250)", "Leaderboard (990x90)"])

        select "DHTML (1x1)", from: "Publicity Formats"
        select "Footer (980x450)", from: "Publicity Formats"
        fill_in "Adunit", with: "FortyTwo"
        fill_in "Story Adunit", with: "Seven"
        fill_in "Gallery Adunit", with: "One"

        click_button "Save"
      end
      page.should have_css('.alert-info', text: "Page was successfully updated")

      click_link "Advertising"

      within "#publicity-tab" do

        page.should have_select('Publicity Formats', selected: ["Mid-Page Unit (300x250)", "Leaderboard (990x90)", "DHTML (1x1)", "Footer (980x450)"])
        page.should have_field "Adunit", with: "FortyTwo"
        page.should have_field "Story Adunit", with: "Seven"
        page.should have_field "Gallery Adunit", with: "One"

      end
    end

  end

end
