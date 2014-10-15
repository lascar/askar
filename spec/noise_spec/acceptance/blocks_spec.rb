require "spec_helper"

feature "Blocks" do
  background do
    unless example.metadata[:js]
      login_as('user', 'editor')

      @area = create_valid_shared_area(name: 'Cinema > Sidebar')
      @area.blocks = [create_valid_block(sort_order: 'created_at ASC', name: 'Cinema news')]
    end
  end

  scenario 'html block empty and after full' do
    name_block = 'Cinema html'
    @area.blocks = [create_valid_block(sort_order: 'created_at ASC', name: name_block, content_type: 'html')]
    visit areas_path
    click_link @area.name
    page.should have_css('.panel-header h3 strong', text: name_block + ' (empty)')

    header = find('.panel-header h3 strong', text: name_block).parent
    within header do
      click_link 'Edit Block'
    end

    fill_in 'block_html_code', with: 'html code'

    click_button "Save"
    page.should_not have_css('.panel-header h3 strong', text: name_block + ' (empty)')
    page.should have_css('.panel-header h3 strong', text: name_block)
  end

  context 'a block without category' do
    before do
      @options = prepare_block
      visit areas_path
      find('tr.area td label a', text: @options[:area_name]).click
      click_button('Publish')
    end

    scenario 'a story with a category appears in the block when this one is attributed this category', :js => true do
      block_header = find('.panel-header', text: @options[:block_name])
      block_header.click
      expect(page).to_not have_selector('.headline', :text => @options[:story_title_1])
      within(block_header) do
        click_link 'Edit'
      end
      select_from_chosen(@options[:category_name_1], from: 'block_category_ids')
      within('#modal') do
        click_button('Save')
      end
      find('.panel-header h3', text: @options[:block_name]).click
      expect(page).to have_selector('.headline', :text => @options[:story_title_1])
    end

  end

  context 'a block with a category' do
    before do
      @options = prepare_block
      block = Block.where(name: @options[:block_name]).first
      category = Category.where(name: @options[:category_name_1]).first
      block.categories << category
      visit areas_path
      find('tr.area td label a', text: @options[:area_name]).click
      click_button('Publish')
    end

    scenario 'a story with a category disappears of a block when the category is removed from the block', :js => true do
      block_header = find('.panel-header', text: @options[:block_name])
      block_header.click
      expect(page).to have_selector('.headline', :text => @options[:story_title_1])
      within(block_header) do
        click_link 'Edit'
      end
      within find('.search-choice', text: @options[:category_name_1]) do
        find('a').click
      end

      within('#modal') do
        click_button('Save')
      end
      block_header.click
      expect(page).to_not have_selector('.headline', :text => @options[:story_title_1])
    end
  end

  context 'a block without tag' do
    before do
      @options = prepare_block
      visit areas_path
      find('tr.area td label a', text: @options[:area_name]).click
      click_button('Publish')
    end

    scenario 'a story with a tag appears in the block when this one is attributed this tag', :js => true do
      block_header = find('.panel-header', text: @options[:block_name])
      block_header.click
      expect(page).to_not have_selector('.headline', :text => @options[:story_title_1])
      within(block_header) do
        click_link 'Edit'
      end
      select_from_chosen(@options[:tag_name_1], from: 'block_tag_ids')
      within('#modal') do
        click_button('Save')
      end
      find('.panel-header h3', text: @options[:block_name]).click
      expect(page).to have_selector('.headline', :text => @options[:story_title_1])
    end
  end

  context 'a block with a tag' do
    before do
      @options = prepare_block
      block = Block.where(name: @options[:block_name]).first
      tag = ActsAsTaggableOn::Tag.where(name: @options[:tag_name_1]).first
      block.tags << tag
      visit areas_path
      find('tr.area td label a', text: @options[:area_name]).click
      click_button('Publish')
    end

    scenario 'a story with a tag disappears of a block when the tag is removed from the block', :js => true do
      block_header = find('.panel-header', text: @options[:block_name])
      block_header.click
      expect(page).to have_selector('.headline', :text => @options[:story_title_1])
      within(block_header) do
        click_link 'Edit'
      end
      within find('.search-choice', text: @options[:tag_name_1]) do
        find('a').click
      end

      within('#modal') do
        click_button('Save')
      end
      block_header.click
      expect(page).to_not have_selector('.headline', :text => @options[:story_title_1])
    end
  end

  scenario 'headline block empty and after full' do
    name_block = 'Cinema news'
    visit areas_path
    click_link @area.name
    page.should have_css('.panel-header h3 strong', text: name_block + ' (empty)')

    header = find('.panel-header h3 strong', text: name_block).parent
    within header do
      click_link 'Add Headline'
    end
    fill_in 'headline_title', with: 'Title of Headline'
    fill_in 'headline_url', with: 'Url of Headline'

    click_button "Save"
    page.should_not have_css('.panel-header h3 strong', text: name_block + ' (empty)')
    page.should have_css('.panel-header h3 strong', text: name_block)
  end

  context "sourceless" do

    scenario "Adding to an area" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)

      click_link "Add standalone block"

      fill_in "Name", with: "Cinema fashion news"
      select "Unordered List", from: "Style Hint"

      click_button "Save"

      page.should have_css(".alert-info", text: "Block was successfully created")
      page.should have_css(".block_containers .block", count: 2)

      page.should have_css(".block_containers .block .info", text: "Cinema fashion news: (standalone headlines)")

    end

    scenario "Editing a headline block" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)

      find(".block_containers .block").click_link "Edit"

      select "Reverse Chronological", from: 'Sort order'
      select "15", from: 'Number of headlines'
      click_button "Save"

      page.should have_css(".alert-info", text: "Block was successfully updated")
      page.should have_css(".block_containers .block", count: 1)
      page.should have_css(".block_containers .block .info", text: "Cinema news: (15 standalone headlines)")
    end

  end

  context "Headline source is a Category" do
    background do
      @category1 = create_valid_category(name: "Cinema")
      @category1 = create_valid_category(name: "Documentaries")
    end

    scenario "Creating inside an area" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)


      click_link "Add headlines block"

      fill_in "Name", with: "Cinema fashion news"
      select "Reverse Chronological", from: 'Sort order'
      select "15", from: 'Number of headlines'
      select "Cinema", from: "Categories"
      select "Documentaries", from: "Categories"

      click_button "Save"
      page.should have_css(".alert-info", text: "Block was successfully created")
      page.should have_css(".block_containers .block", count: 2)
      page.should have_css(".block_containers .block .info", text: "Cinema fashion news: (15 headlines from: Categories: Cinema, Documentaries)")
    end

    scenario "Receiving a newly categorised and published Story" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)

      click_link "Add headlines block"

      fill_in "Name", with: "Cinema fashion news"
      select "Reverse Chronological", from: 'Sort order'
      select "Cinema", from: "Categories"
      select "Documentaries", from: "Categories"

      click_button "Save"

      visit root_path
      click_link "New Story"

      select "Cinema", from: "Section"
      fill_in "Title", with: "Antonio Banderas retires"
      fill_in "Excerpt", with: "Antonio Banderas retires the world of cinema."
      fill_in "Body", with: "Antonio Banderas retires..."
      click_button "Save"

      within 'form.categorisation' do
        fill_in "story_tag_list", with: "one, two"
        click_button "Save"
      end

      click_link "Images"
      click_link "Image rights"

      select "Getty Images", from: "Agency"
      fill_in "Photographer", with: "Helmut Newton"
      click_button 'Save'

      click_link "All images"

      attach_file "Add images", fixture_file("story_image.jpg")
      click_button "Add images"

      click_link "All images"

      all('#images-list .media a')[0].click

      find('ul.crops').click_link 'Home Page (5:3)'
      fill_in "Left", with: "10"
      fill_in "Top", with: "20"
      fill_in "Width", with: "500"
      fill_in "Height", with: "300"
      click_button "Add crop"

      fill_in "Caption", with: "Some caption"
      click_button 'Set caption'
      visit root_path

      click_link "Antonio Banderas retires"

      click_link "Publish"

      visit areas_path

      click_link 'Cinema > Sidebar'

      page.should have_css(".headline", text: "Antonio Banderas retires")

    end

    scenario "Receiving a newly categorised but unpublished Story" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)

      click_link "Add headlines block"

      fill_in "Name", with: "Cinema fashion news"
      select "Reverse Chronological", from: 'Sort order'
      select "Cinema", from: "Categories"
      select "Documentaries", from: "Categories"

      click_button "Save"

      visit root_path
      click_link "New Story"
      select "Cinema", from: "Section"
      fill_in "Title", with: "Antonio Banderas retires"
      fill_in "Excerpt", with: "Antonio Banderas retires the world of cinema."
      fill_in "Body", with: "Antonio Banderas retires..."
      click_button "Save"

      visit areas_path

      click_link 'Cinema > Sidebar'

      page.should_not have_css(".headline", text: "Antonio Banderas retires")

    end

    scenario "BUG: Removing all sources from a headline block" do
      pending "FIXME"
    end

  end

  context "Headline source is a Tag" do

    background do
      create_valid_category(name: "Cinema")
      create_valid_tag(name: 'Queen Elizabeth II')
      create_valid_tag(name: 'Prince Harrry of Wales')
    end

    scenario "creating inside an Area" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)

      click_link "Add headlines block"

      fill_in "Name", with: "Cinema fashion news"
      select "10", from: 'Number of headlines'
      select "Reverse Chronological", from: 'Sort order'
      select "Queen Elizabeth II", from: "Tags"
      select "Prince Harrry of Wales", from: "Tags"

      click_button "Save"

      page.should have_css(".alert-info", text: "Block was successfully created")

      page.should have_css(".block_containers .block", count: 2)

      page.should have_css(".block_containers .block .info", text: "Cinema fashion news: (10 headlines from: Tags: Prince Harrry of Wales, Queen Elizabeth II)")
    end

    scenario "Receiving a newly tagged and published Story" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)

      click_link "Add headlines block"

      fill_in "Name", with: "Cinema fashion news"
      select "Reverse Chronological", from: 'Sort order'
      select "Queen Elizabeth II", from: "Tags"
      select "Prince Harrry of Wales", from: "Tags"

      click_button "Save"

      visit root_path
      create_published_story(title: "Prince Harrry lost his clothes, again", creator: 'user')

      visit root_path

      find('.stories .story').click_link "Prince Harrry lost his clothes, again"
      click_link "Categorization"

      within 'form.categorisation' do
        fill_in "story_tag_list",   with: 'Prince Harrry of Wales'
        click_button "Save"
      end

      click_link "Publish"

      visit areas_path

      click_link 'Cinema > Sidebar'

      page.should have_css(".headline", text: "Prince Harrry lost his clothes, again")

    end

    scenario "Receiving a newly tagged but unpublished Story" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)

      click_link "Add headlines block"

      fill_in "Name", with: "Cinema fashion news"
      select "Reverse Chronological", from: 'Sort order'
      select "Queen Elizabeth II", from: "Tags"
      select "Prince Harrry of Wales", from: "Tags"

      click_button "Save"

      visit root_path
      click_link "New Story"
      select "Cinema", from: "Section"
      fill_in "Title", with: "Prince Harrry lost his clothes, again"
      fill_in "Excerpt", with: "Prince Harrry lost his clothes, again"
      fill_in "Body", with: "Prince Harrry lost his clothes, again..."
      click_button "Save"

      visit root_path
      click_link "Prince Harrry lost his clothes, again"
      click_link "Categorization"
      fill_in "story_tag_list",   with: 'Prince Harrry of Wales'
      click_button "Save"

      visit areas_path

      click_link 'Cinema > Sidebar'

      page.should_not have_css(".headline", text: "Prince Harrry lost his clothes, again")

    end

  end

  scenario "Limit number of headlines per block" do
    visit areas_path

    click_link 'Cinema > Sidebar'
    page.should have_css(".block_containers .block", count: 1)

    find('.block').click_link('Edit')

    select "3", from: "Number of headlines"
    click_button "Save"

    find('.block').click_link('Edit')
    page.should have_field("Number of headlines", with:"3")
  end

  scenario "Selecting a style hint" do
    visit areas_path

    click_link 'Cinema > Sidebar'
    page.should have_css(".block_containers .block", count: 1)

    find('.block').click_link('Edit')

    select "Buttons", from: "Style Hint"
    click_button "Save"

    find('.block').click_link('Edit')
    page.should have_select("Style Hint", selected:"Buttons")
  end

  scenario "Disabling and enabling blocks" do
    @area.blocks.clear
    @area.blocks << create_valid_block(name: "HTML block", content_type: "html")
    @area.blocks << create_valid_block(name: "Standalone block", content_type: "standalone")
    @area.blocks << create_valid_block(name: "Headlines block", content_type: "headlines")

    visit root_path
    click_link "Edit Shared Areas"

    click_link "Cinema > Sidebar"

    page.should have_css('.block_containers .block_container', count: 3)

    find('.block_containers .block_container', text: "HTML block").click_link "Disable"

    page.should have_css('.block_containers .block_container', count: 2)
    page.should have_css('.disabled_block_containers .block_container', count: 1)

    find('.block_containers .block_container', text: "Standalone block").click_link "Disable"

    page.should have_css('.block_containers .block_container', count: 1)
    page.should have_css('.disabled_block_containers .block_container', count: 2)

    find('.block_containers .block_container', text: "Headlines block").click_link "Disable"

    page.should_not have_css('.block_containers .block_container')
    page.should have_css('.disabled_block_containers .block_container', count: 3)

    find('.disabled_block_containers .block_container', text: "HTML block").click_link "Enable"
    find('.disabled_block_containers .block_container', text: "Standalone block").click_link "Enable"
    find('.disabled_block_containers .block_container', text: "Headlines block").click_link "Enable"

    page.should have_css('.block_containers .block_container', count: 3)
    page.should_not have_css('.disabled_block_containers .block_container')
  end

  context "with HTML content" do

    scenario "Adding to an area" do
      visit areas_path

      click_link 'Cinema > Sidebar'
      page.should have_css(".block_containers .block", count: 1)

      click_link "Add html block"

      fill_in "Name", with: "Cinema publicity"
      fill_in "HTML code", with: "<wadus></wadus>"

      click_button "Save"

      page.should have_css(".alert-info", text: "Block was successfully created")
      page.should have_css(".block_containers .block", count: 2)
      page.should have_css(".block_containers .block .info", text: "Cinema publicity: (HTML block)")
    end

  end

  context "shared Block" do

    before(:each) do
      @page = create_valid_page(title: "Home Page")
      @region = create_valid_region(name: "Side column")
      @area = create_valid_area(name: "Ads")

      @region.areas << @area
      @page.regions << @region

      @block = create_valid_shared_block(name: "Shared publicity block")
    end

    scenario "linking to an Area" do
      visit root_path
      click_link "Pages"
      click_link "Home Page"
      click_link "Side column"

      click_link "Add shared block"
      select "Shared publicity block", from: "Choose A Shared Block"
      click_button "Save"

      page.should have_css('.block_containers .block_container', text: "Shared publicity block")
    end

    scenario "unlinking from an Area" do
      @area.blocks << @block
      visit root_path
      click_link "Pages"
      click_link "Home Page"
      click_link "Side column"

      page.should have_css('.block_containers .block_container', text: "Shared publicity block")

      find('.block_containers .block_container button', text: "Unlink").click

      page.should_not have_css('.block_containers .block_container', text: "Shared publicity block")
    end
  end
end
