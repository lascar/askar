require 'spec_helper'

feature "Areas" do

  background do
    login_as('user', 'editor')

    @area = create_valid_shared_area(name: "Cinema > Sidebar")
    @area.blocks << create_valid_block(sort_order: 'created_at ASC')
  end

  context "Shared Area" do
    name_area = "Page_1 > Sidebar"
    background do
      area = create_valid_shared_area(name: name_area)
      visit areas_path
      click_link name_area
    end

    it_behaves_like "a correct header that indicates when it's empty" do
      let(:element) {".panel-header h3"}
      let(:regexs) {[name_area, "\(empty\)"]}
    end
  end

  context "Not Shared Area" do
    name_area = "Page_1 > Sidebar"
    background do
      page_new = create_valid_page(title: "Page_1")
      region = create_valid_region(name: "Region_1")
      page_new.regions << region
      area = create_valid_area(name: name_area)
      container = create_valid_container(region_id: region.id, area_id: area.id)
      visit pages_path
      click_link 'Page_1'
      click_link "Region_1"
    end

    it_behaves_like "a correct header that indicates when it's empty" do
      let(:element) {".panel-header h3"}
      let(:regexs) {[name_area, "\(empty\)"]}
    end

  end

  scenario "Searching" do
    create_valid_shared_area(name: "Main News area")
    create_valid_shared_area(name: "Secondary News area")
    create_valid_shared_area(name: "Sidebar")

    visit areas_path
    page.should have_content 'Main News area'
    page.should have_content 'Secondary News area'
    page.should have_content 'Sidebar'

    fill_in "Search for", with: "Sidebar"
    click_button "Search"

    page.should have_content 'Sidebar'
    page.should_not have_content 'News area'

  end

  scenario "Creating a new one" do
    visit areas_path

    click_link "New Area"
    fill_in "Name", with: "Celebrities > Sidebar"
    click_button "Save"

    page.should have_css(".alert-info", text: "Area was successfully created")
    page.should have_content("Area: Celebrities > Sidebar")
  end

  scenario "Cloning an existing one" do
    visit areas_path

    find('.area', text:'Cinema > Sidebar').click_button "Duplicate"

    page.should have_css(".alert-info", text: "Area was successfully duplicated")
    page.should have_css(".block_containers .block", count: 1)

    find('.area h3', text:'Cinema > Sidebar (duplicate)').click_link '(Edit)'

    fill_in 'Name', with: 'Celebrities > Sidebar'
    click_button 'Save'

    page.should have_content("Area: Celebrities > Sidebar")
  end

  scenario "Changing the title" do
    visit areas_path

    click_link 'Cinema > Sidebar'
    find('.area h3', text:'Cinema > Sidebar').click_link '(Edit)'

    fill_in 'Name', with: 'Movies > Sidebar'
    click_button 'Save'

    page.should have_content("Area: Movies > Sidebar")
  end

  scenario "Deleting" do
    visit areas_path
    page.should have_css(".area", count: 1)

    click_button 'Delete'

    page.should_not have_css(".area")
  end

  context "Publishing shared areas" do
    scenario "empty area" do
      visit area_path(@area)
      click_button "Publish"

      page.should have_css(".alert-info", text: "Area was successfully published")

      @base_path = File.dirname(Publisher.publish_path(@area))
      published_files = Dir.glob("#{@base_path}/data.json").map {|f| File.basename(f)}
      published_files.should == ["data.json"]
    end

    scenario "area with blocks" do
      3.times do
        block = create_valid_block
        @area.blocks << block
      end

      visit area_path(@area)
      click_button "Publish"

      page.should have_css(".alert-info", text: "Area was successfully published")

      area_path = File.dirname(Publisher.publish_path(@area))
      published_files = Dir.glob("#{area_path}/data.json").map {|f| File.basename(f)}
      published_files.should == ["data.json"]

      @area.blocks.each do |block|
        block_path = File.dirname(Publisher.publish_path(block))
        published_files = Dir.glob("#{area_path}/data.json").map {|f| File.basename(f)}
        published_files.should == ["data.json"]
      end
    end
  end

end
