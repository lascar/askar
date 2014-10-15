require 'spec_helper'

feature 'Stories' do

  background do
    login_as('user', 'editor') unless example.metadata[:js]

    @results = {}
    @results[:categories] = [['Royalty', []], ['UK', []]]
    @results[:tags]  = ['Monarchy']
    @results[:places] = ['Belfast']
    @results[:people] = ['Queen Elizabeth II']
    @results[:institutions] = ['British Monarchy']
    @results[:brands] = ['Queen']
    @results[:companies] = ['Royal Theater Company']

    TaggingService.stub!(:classify).and_return(@results)

    @home = create_valid_category(name: 'Home')
    @royalty = create_valid_category(name: 'Royalty')
    @general = create_valid_category(name: 'General')
    @celebrities = create_valid_category(name: 'Celebrities')

    @story = create_valid_story(category: @royalty, story_type: 'NewsStory')
  end

  scenario 'Creating a story with basic content' do
    visit root_path

    click_link 'New Story'
    select  'Royalty', from: 'Section'
    fill_in 'Title',   with: 'The Queen Mother rises from the grave'
    fill_in 'Subtitle', with: 'Cheeky monkey'
    fill_in 'Excerpt', with: 'Just your run of the mill royal zombie resurection incident'
    fill_in 'Body',    with: 'Nuff said.'
    click_button 'Save'

    page.should have_css('.alert-info', text: 'Story was successfully created')
    page.should have_field 'Title', with: 'The Queen Mother rises from the grave'
  end

  scenario 'Importing a story from a URL' do
    visit root_path

    ImporterMappings::UK_CA_MAP['royalty']['ukmonarchy'] = 'UK Monarchy'

    ukmonarchy = create_valid_category(name: 'UK Monarchy')
    ukmonarchy.parent = @royalty
    ukmonarchy.save!

    json_response_file = File.new(File.join(NoiseCore::Engine.root, 'spec', 'fixtures', 'webmock', 'prince-william-buckingham-palace-football.json'))
    landscape_image =  File.read(fixture_file('story_image_landscape_5_3_150_90.jpg'))
    portrait_image =  File.read(fixture_file('story_image_portrait_3_4_90_150.jpg'))

    stub_request(:get, 'http://www.hellomagazine.com/royalty/2013100714952/prince-william-buckingham-palace-football?viewas=json-full').to_return(body: json_response_file, status: 200)
    stub_request(:get, 'http://www.hellomagazine.com/imagenes/royalty/2013100714952/prince-william-buckingham-palace-football/0-75-963/buckingham-palace--a.jpg').to_return(body: landscape_image, status: 200)
    stub_request(:get, 'http://www.hellomagazine.com/imagenes/royalty/2013100714952/prince-william-buckingham-palace-football/0-75-997/william-football--a.jpg').to_return(body: portrait_image, status: 200)
    stub_request(:get, 'http://www.hellomagazine.com/imagenes/royalty/2013100714952/prince-william-buckingham-palace-football/0-75-998/william-football1--a.jpg').to_return(body: landscape_image, status: 200)
    stub_request(:get, 'http://www.hellomagazine.com/imagenes/royalty/2013100714952/prince-william-buckingham-palace-football/0-75-999/william-football2--z.jpg').to_return(body: landscape_image, status: 200)

    click_link 'Import Story'
    fill_in 'Story URL', with: 'http://www.hellomagazine.com/royalty/2013100714952/prince-william-buckingham-palace-football'
    click_button 'Import'

    page.should have_content('Story imported successfully')

    page.should have_css('#body-images .media-body p.muted', count: 1, text: 'Story Portrait (3:5)(90x150)')
    page.should have_css('#body-images .media-body p.muted', count: 3, text: 'Story Landscape (5:3)(150x90)')
    page.should have_field 'Tags', with: 'Prince William, William and Kate, British Royals'
    page.should have_select 'Section', selected: 'Royalty'
    page.should have_select 'Secondary categories', selected: 'Royalty > UK Monarchy'

    page.find_field('Body').text.should_not include('/imagenes')

    page.find_field('Body').text.should include('/system/publish/crops')
    page.find_field('Body').text.should include('body_5_3.jpg')
    page.find_field('Body').text.should include('body_3_5.jpg')

    page.find_field('Body').text.should_not include('width=\'610\'')
    page.find_field('Body').text.should_not include('height=\'407\'')

    click_link 'Images'
    click_link 'All images'
    page.should have_css('#images-list .metadata', count: 3, text: 'Story Landscape (5:3) and Gallery Landscape (5:3)')
    page.should have_css('#images-list .metadata', count: 1, text: 'Story Portrait (3:5) and Gallery Portrait (3:5)')

  end

  scenario 'Missing content for creation' do
    ['Story', 'Recipe', 'Biography', 'Magazine', 'Album'].each do |document|
      campos = document === 'Magazine' ? ['Section', 'Title', 'Excerpt'] : ['Section', 'Title', 'Excerpt', 'Body']
      campos.each do |campo_missing|
        visit root_path
        click_link 'New ' + document
        create_missing_content(campos - [campo_missing])
        click_button 'Save'
        page.should have_selector('#errorExplanation', text: campo_missing === 'Section' ? Categorisation : campo_missing)
      end
    end
  end

  context 'Home page' do

    background do
      create_published_story(title: 'My published story', creator: 'user')
      create_published_story(title: 'Other published story', creator: 'user2')
      create_valid_story(title: 'My draft story', creator: 'user')
    end

    scenario 'other published stories' do
      visit root_path
      page.should have_css('td', text: 'Other published story')
    end

    scenario 'my published stories' do
      visit root_path
      page.should have_css('h3', text: 'Published')
      page.should have_css('ul li a', text: 'My published story')
    end

    scenario 'my draft stories' do
      visit root_path
      page.should have_css('h3', text: 'Draft')
      page.should have_css('ul li a', text: 'My draft story')
    end

    scenario "admin can see everyone's draft stories" do
      create_valid_story(title: 'Another draft story', creator: 'other_user')

      login_as('user', 'admin')
      visit root_path

      page.should have_css('h3', text: "Everyone's drafts")
      page.should have_css('ul li', text: 'My draft story (user)')
      page.should have_css('ul li', text: 'Another draft story (other_user)')
    end

  end

  context 'Categorising' do

    background do
      TaggingService.stub!(:classify).and_return({people: ['Queen Elizabeth II'], tags: ['Zombies'], categories: [['Aristocracy', []]]})
      @story_royal = create_valid_story(category: @royalty, title:'The Queen Mother rises from the grave', creator: 'user')
      @story_royal.categorize!
    end

    scenario 'Changing the primary category' do
      visit root_path

      click_link 'The Queen Mother rises from the grave'

      # Home category should not appear in primary category select
      page.should_not have_xpath "//select[@id = 'story_categorisation_attributes_category_id']/option[text() = 'Home']"

      within 'form.section' do
        select  "#{@general.name}", from: 'Section'
        click_button 'Save'
      end
      page.should have_css('.alert-info', text: 'Story was successfully updated')
    end

    scenario "Primary category doesn't appear in secondary categories select" do
      visit root_path

      click_link 'The Queen Mother rises from the grave'

      click_link 'Categorization'

      page.should_not have_xpath "//select[@id = 'story_secondary_category_ids']/option[text() = '#{@royalty.name}']"
    end

    scenario 'Automatic categorisation by the tagging service' do
      visit root_path

      click_link 'The Queen Mother rises from the grave'

      click_link 'Categorization'

      # Until we have the new tagging service working the automatic secondary categories will be disabled
      # page.should have_select('Secondary categories', selected: 'Aristocracy')
      page.should have_field('Tags', with: 'Zombies')
      page.should have_field('People', with: 'Queen Elizabeth II')
    end

    scenario 'Modifying secondary categories' do
      visit root_path

      click_link 'The Queen Mother rises from the grave'
      click_link 'Categorization'

      within 'form.categorisation' do
        select 'Celebrities', from: 'Secondary categories'

        click_button 'Save'
      end
      page.should have_css('.alert-info', text: 'Story was successfully updated')

      visit root_path
      click_link 'The Queen Mother rises from the grave'

      click_link 'Categorization'

      within 'form.categorisation' do
        page.should have_select('Secondary categories', selected: 'Celebrities')
        page.should_not have_select('Secondary categories', selected: 'Aristocracy')
      end
    end

  end

  context 'Navigating' do

    background do
      @story_royal = create_valid_story(title:'The Queen Mother rises from the grave')
      create_valid_story(title:'King Harry back in the UK')
      @story_royal.secondary_categories = [@royalty]
      @story_royal.update_attribute(:first_published_at, DateTime.new(2012, 10, 10))
      @story_royal.update_attribute(:published_at, DateTime.new(2012, 10, 10))
      @story_pie = create_valid_story(title: 'A wonderful cheese cake', story_type: 'Recipe', tag_list: 'Retro, fashion')
      @story_pie.update_attribute(:first_published_at, DateTime.new(2012, 9, 25, 14, 53))
      @story_pie.update_attribute(:published_at, DateTime.new(2012, 10, 25, 10, 23))
    end

    scenario 'Basic search notice by keywords with results' do
      visit root_path
      fill_in 'Search for',   with: 'The Queen Mother'

      click_button 'Search'

      page.should have_css('td', text: 'The Queen Mother rises from the grave')
      page.should_not have_css('td', text: 'King Harry')
    end

    scenario 'Basic search notice by keywords not results' do
      visit root_path
      fill_in 'Search for',   with: 'apple'

      click_button 'Search'

      page.should have_css('.alert-warning', text: 'Not found any Story')

    end

    scenario 'Advanced search by any keywords and one category'  do
      visit root_path
      fill_in 'Search for',   with: 'The Queen'
      select  'Royalty', from: 'Section'

      click_button 'Search'

      page.should have_css('td', text: 'The Queen Mother rises from the grave')
      page.should_not have_css('td', text: 'King Harry')

    end

    scenario 'Advanced search by tag' do
      visit root_path
      select  'Retro', from: 'Tag'

      click_button 'Search'

      page.should have_css('td', text: 'A wonderful cheese cake')
      page.should_not have_css('td', text: 'King Harry')
    end

    scenario 'Advanced search by story type' do
      visit root_path
      select  'Recipe', from: 'Story type'

      click_button 'Search'

      page.should have_css('td', text: 'A wonderful cheese cake')
      page.should_not have_css('td', text: 'King Harry')
    end

    scenario 'Advanced search by first publication date', :js => true do
      visit root_path
      find('.advanced-shortcut').click
      within '#advanced-search' do
        fill_in  'q[first_published_at_as_date_dategteq]', with: '09/20/2012'
        fill_in  'q[first_published_at_as_date_datelteq]', with: '10/09/2012'

        click_button 'Search'
      end
      save_and_open_page('page.html')
      page.should have_css('td', text: 'A wonderful cheese cake')
      page.should_not have_css('td', text: 'Queen Mother')
    end

    scenario 'Date column in search results' do
      visit root_path
      within '#advanced-search' do
        fill_in  'First published between', with: '2012-09-13'
        fill_in  'q[first_published_at_as_date_datelteq]', with: '2012-09-29'

        click_button 'Search'
      end

      page.should have_css('td', text: '25 Oct 2012')
    end
  end

  context 'Editorial Versions' do

    background do
      @editorial_version = create_valid_editorial_version(type_version: 'Tablet' )
      @editorial_version.story = @story
    end

    scenario 'Edit a Tablet editorial_version with basic content' do
      visit edit_story_path(@story)

      click_link 'TABLET'
      within('#Tablet-version') do

        fill_in 'Title',   with: 'The Queen Mother is married once again'
        fill_in 'Subtitle', with: 'Cheeky monkey'
        fill_in 'Excerpt', with: 'Just your run of the mill royal zombie resurection incident'
        fill_in 'Body',    with: 'Nuff said.'
      end
      find('#story-content').click_button 'Save'

      page.should have_css('.alert-info', text: 'Story was successfully updated')

      click_link 'TABLET'

      within('#Tablet-version') do
        page.should have_field('Title', with: 'The Queen Mother is married once again')
        page.should have_field('Subtitle', with: 'Cheeky monkey')
        page.should have_field('Excerpt', with: 'Just your run of the mill royal zombie resurection incident')
        page.should have_field('Body', with: 'Nuff said.')
      end
    end

    scenario 'Clearing attributes to inherit from story' do
      visit edit_story_path(@story)

      click_link 'TABLET'
      within('#Tablet-version') do

        fill_in 'Title',   with: ''
        fill_in 'Subtitle',   with: ''
        fill_in 'Excerpt', with: ''
        fill_in 'Body',    with: ''
      end
      find('#story-content').click_button 'Save'

      visit edit_story_path(@story)
      click_link 'TABLET'

      within('#Tablet-version') do
        page.should have_field('Title', with: @story.title)
        page.should have_field('Subtitle', with: @story.subtitle)
        page.should have_field('Excerpt', with: @story.excerpt)
        page.should have_field('Body', with: @story.body)
      end
    end

  end

  # TODO: Group tests by story type context?

  context 'Properties' do

    context 'Properties depending on story type' do

      before(:each) do
        @property_types = []
      end

      after(:each) do
        click_button 'Save'

        page.should have_css('.alert-info', text: 'Story was successfully created')

        @property_types.map(&:delete)
      end

      scenario 'creating news story' do
        3.times do |n|
          @property_types << create_valid_property_type(name: "news_story_property_#{n}", story_type: 'NewsStory')
        end

        visit root_path
        click_link 'New Story'

        select  'Royalty',                from: 'Section'
        fill_in 'Title',                  with: 'The Queen Mother rises from the grave'
        fill_in 'Subtitle',               with: 'Cheeky monkey'
        fill_in 'Excerpt',                with: 'Just your run of the mill royal zombie resurection incident'
        fill_in 'Body',                   with: 'Nuff said.'

        3.times do |n|
          page.should have_field("news_story_property_#{n}", count: 1)
          fill_in "news_story_property_#{n}",  with: 'John Doe'
        end
      end

      scenario 'creating biography' do
        3.times do |n|
          @property_types << create_valid_property_type(name: "biography_property_#{n}", story_type: 'Biography')
        end

        visit root_path
        click_link 'New Biography'

        select  'Royalty',              from: 'Section'
        fill_in 'Title',                with: 'Elizabeth II'
        fill_in 'Subtitle',             with: 'Cheeky monkey'
        fill_in 'Excerpt',              with: "A queen's life"
        fill_in 'Body',                 with: 'She was born a lot of time ago...'

        3.times do |n|
          page.should have_field("biography_property_#{n}", count: 1)
          fill_in "biography_property_#{n}",  with: '1965-04-21'
        end
      end

      scenario 'creating recipe' do
        3.times do |n|
          @property_types << create_valid_property_type(name: "recipe_property_#{n}", story_type: 'Recipe')
        end

        visit root_path
        click_link 'New Recipe'

        select  'Royalty',            from: 'Section'
        fill_in 'Title',              with: "Fabulous Baker Brothers' Scotch Egg"
        fill_in 'Subtitle',           with: 'Cheeky monkey'
        fill_in 'Excerpt',            with: 'The recent Scotch Egg renaissance...'
        fill_in 'Body',               with: 'Bring a big pan of water to a simmer, carefully lower in the eggs...'

        3.times do |n|
          page.should have_field("recipe_property_#{n}", count: 1)
          fill_in "recipe_property_#{n}",  with: 'Snack'
        end
      end

      scenario 'creating magazine' do
        3.times do |n|
          @property_types << create_valid_property_type(name: "magazine_property_#{n}", story_type: 'Magazine')
        end

        visit root_path
        click_link 'New Magazine'

        page.should have_xpath("//textarea[contains(@class, 'redactor') and @id='story_excerpt']")
        page.should_not have_field('Body')
        page.should_not have_field('Subtitle')
        page.should_not have_css('.tabs', text: 'Categorization')

        select  'Royalty',              from: 'Section'
        fill_in 'Title',                with: 'Elizabeth II'
        fill_in 'Excerpt',              with: "A queen's life"

        3.times do |n|
          page.should have_field("magazine_property_#{n}", count: 1)
          fill_in "magazine_property_#{n}",  with: '10000'
        end
      end

    end

    scenario 'Property data types' do
      properties = []
      %w[date string text].each do |data_type|
        properties << create_valid_property_type(name: "property_#{data_type}", data_type: data_type, story_type: 'NewsStory')
      end

      visit root_path
      click_link 'New Story'

      page.should have_css('input#story_properties_attributes_0_value', count: 1)

      page.should have_css('input#story_properties_attributes_1_value', count: 1)

      page.should have_css('textarea#story_properties_attributes_2_value', count: 1)

      properties.map(&:delete)
    end

    scenario 'Required properties for story creation'

    scenario 'Do not repeat properties!' do
      property = create_valid_property_type(name: 'property_0', story_type: 'NewsStory')

      visit root_path
      click_link 'New Story'

      select  'Royalty',                from: 'Section'
      fill_in 'Title',                  with: "The Queen's Father rises from the grave"
      fill_in 'Subtitle',               with: 'Cheeky monkey'
      fill_in 'Excerpt',                with: 'Just your run of the mill royal zombie resurection incident'
      fill_in 'Body',                   with: 'Nuff said.'

      click_button 'Save'

      visit root_path
      click_link "The Queen's Father rises from the grave"

      page.should have_field('property_0', count: 1)

      property.delete
    end

  end

  context 'Publishing' do

    before(:each) do
      @story_royal = create_valid_story(category: @royalty, title:'The Queen Mother rises from the grave')
    end

    context 'with all required elements' do

      before(:each) do
        @story.categorize!
        visit edit_story_path(@story)
        click_link 'Images'

        click_link 'Image rights'
        select 'Getty Images', from: 'Agency'
        fill_in 'Photographer', with: 'Helmut Newton'
        click_button 'Save'

        click_link 'All images'

        attach_file 'Add images', fixture_file('story_image.jpg')
        click_button 'Add images'

        click_link 'All images'

        all('#images-list .media a')[0].click

        find('ul.crops').click_link 'Home Page (5:3)'
        fill_in 'Left', with: '1'
        fill_in 'Top', with: '2'
        fill_in 'Width', with: '500'
        fill_in 'Height', with: '300'
        click_button 'Add crop'

        fill_in 'Caption', with: 'Some caption'
        click_button 'Set caption'
      end

      scenario 'generates all required json files' do
        visit edit_story_path(@story)
        click_link 'Publish'

        page.should have_css('.alert-info', text: 'Story was successfully published')

        @base_path = File.dirname(Publisher.publish_path(@story))
        @crop_paths = []
        @story.crops.each do |crop|
          @crop_paths << File.dirname(Publisher.publish_path(crop))
        end

        published_files = Dir.glob("#{@base_path}/*").collect {|f| File.basename(f)}
        published_images = []
        @crop_paths.each do |crop_path|
          published_images << Dir.glob("#{crop_path}/*.jpg").map {|f| File.basename(f)}
        end
        published_files.should == ['data.json']
        published_images.flatten.sort.should == ['featured_5_3.jpg', 'thumb_featured_5_3.jpg']
      end

      scenario 'Redirects to Story after publishing' do
        visit edit_story_path(@story)

        click_link 'Publish'

        page.should have_css('.alert-info', text: 'Story was successfully published')

        page.should have_field('Title', with: @story.title)
      end
    end

    context 'without all required elements' do
      scenario "shows error message and doesn't publish story" do
        visit edit_story_path(@story)
        click_link 'Publish'

        page.should have_css('.alert-error', text: "Story can't be published because of missing elements")
        page.should have_css('.alert-error', text: 'Story is not categorized.')
        page.should have_css('.alert-error', text: 'Story is missing default image rights.')
        page.should have_css('.alert-error', text: "Story doesn't have the required featured crop.")
      end
    end

  end

  context 'SEO' do
    scenario 'Inheriting Title, Description, and Keywords from story' do
      @story.update_attributes(title: 'Story title', excerpt: 'Story excerpt')
      @story.tag_list = 'Tag1, Tag2'
      @story.person_list = 'Person1, Person2'
      @story.secondary_categories << create_valid_category(name: 'Category 2')
      @story.save!

      visit edit_story_path(@story)
      click_link 'SEO'

      page.should have_field 'Meta title', with: 'Story title'
      page.should have_field 'Meta description', with: 'Story excerpt'
      page.should have_field 'Meta keywords', with: 'Tag1, Tag2, Person1, Person2, Royalty, Category 2'
    end

    context 'without seo role' do
      scenario 'Creating seo fields' do
        login_as('user', 'reporter')

        visit edit_story_path(@story)

        page.should_not have_css('.nav.nav-tabs a', text: 'SEO')
      end
    end

    context 'with seo role' do
      scenario 'Creating seo fields' do
        login_as('user', 'seo')

        visit edit_story_path(@story)
        find('.nav.nav-tabs').click_link 'SEO'

        within '#seo-tab' do
          fill_in 'Meta title',   with: 'The Queen Mother'
          fill_in 'Meta description',   with: 'The Queen Mother rises from the grave'
          fill_in 'Meta keywords',   with: 'UK, Queen Mother, Royal, London'

          fill_in 'Base url',   with: 'http://hola.com'
          fill_in 'Redirection',   with: 'http://hola.com'
          fill_in 'Canonical',   with: 'http://www.hola.com/tags/hombre/el-look-de/'

          click_button 'Save'
        end
        page.should have_css('.alert-info', text: 'Story was successfully updated')
      end
    end

  end

  scenario 'Associating with a Sibebar area' do
    create_valid_shared_area(name: 'Advertising')
    create_valid_shared_area(name: 'Sport')

    visit edit_story_path(@story)

    within 'form.other_data' do
      select 'Advertising', from: 'Sidebar'
      click_button 'Save'
    end

    page.should have_css('.alert-info', text: 'Story was successfully updated')
    page.should have_select('Sidebar', selected: 'Advertising')
  end

  scenario 'Publicity codes' do
    @story.update_attributes(pageid: 'ABC', pageid_name: 'ABC-name')
    @story.update_attributes(gallery_pageid: 'CBA', gallery_pageid_name: 'CBA-name')

    visit edit_story_path(@story)

    find('.nav.nav-tabs').click_link 'Advertising'
    within '#publicity-tab' do
      page.should have_field('Adunit', with: 'ABC-name')

      page.should have_field('Gallery Adunit', with: 'CBA-name')

      select 'DHTML (1x1)', from: 'Publicity Formats'
      select 'Footer (980x450)', from: 'Publicity Formats'

      fill_in 'Adunit', with: 'QWERTY-name'

      fill_in 'Gallery Adunit', with: 'DVORAK-name'

      click_button 'Save'
    end

    page.should have_css('.alert-info', text: 'Story was successfully updated')

    find('.nav.nav-tabs').click_link 'Advertising'
    within '#publicity-tab' do

      page.should have_field('Adunit', with: 'QWERTY-name')

      page.should have_field('Gallery Adunit', with: 'DVORAK-name')

    end
  end

  context 'Preview a story' do

    before(:each) do
      @story_royal = create_valid_story(category: @royalty, title:'The Queen Mother rises from the grave', creator: 'user')
      @story_royal.categorize!
    end

    scenario 'with images' do
      visit edit_story_path(@story_royal)
      click_link 'Images'

      click_link 'Image rights'
      select 'Getty Images', from: 'Agency'
      fill_in 'Photographer', with: 'Helmut Newton'
      click_button 'Save'

      click_link 'All images'

      attach_file 'Add images', fixture_file('story_image.jpg')
      click_button 'Add images'

      click_link 'All images'

      all('#images-list .media a')[0].click

      find('ul.crops').click_link 'Home Page (5:3)'
      fill_in 'Left', with: '1'
      fill_in 'Top', with: '2'
      fill_in 'Width', with: '500'
      fill_in 'Height', with: '300'
      click_button 'Add crop'

      fill_in 'Caption', with: 'Some caption'
      click_button 'Set caption'

      visit edit_story_path(@story_royal)
      click_link 'Preview'

      prefix = Publisher.first_preview_path

      @base_path = File.dirname(Publisher.publish_path(@story_royal, prefix))

      preview_files = Dir.glob("#{@base_path}/data.json").collect {|f| File.basename(f)}
      preview_images = Dir.glob("#{prefix}/crops/**/*.jpg").map {|f| File.basename(f)}
      preview_files.should == ['data.json']
      preview_images.sort.should == ['featured_5_3.jpg', 'thumb_featured_5_3.jpg'].sort
    end
  end

  context 'Magazine creation and publication' do

    before(:each) do
      create_valid_category(name: 'Magazine', document_type: 'magazine')
      PropertyType.create(story_type: 'Magazine', name: 'Issue')

      visit root_path
      click_link 'New Magazine'

      page.should have_xpath("//textarea[contains(@class, 'redactor') and @id='story_excerpt']")
      page.should_not have_field('Body')
      page.should_not have_field('Subtitle')
      page.should_not have_select('Section')
      page.should_not have_css('.tabs', text: 'Categorization')

      fill_in 'Title', with: 'HELLO! Magazine'
      fill_in 'Excerpt', with: 'First issue'

      fill_in 'Issue', with: '1'

      click_button 'Save'

      page.should_not have_css('.tabs', text: 'Categorization')
      page.should_not have_select('Secondary categories')

      @magazine_url = current_url
      click_link 'Images'

      attach_file 'Add images', fixture_file('story_image.jpg')
      click_button 'Add images'
    end

    scenario 'Creating a Magazine' do
      click_link 'All images'

      page.should have_css('#images-list .media-body .metadata', text: 'Full Size')
    end

    scenario 'Publishing a Magazine' do

      # click_button 'Save'
      click_link 'Images'

      click_link 'All images'

      all('#images-list .media a')[0].click

      find('ul.crops').click_link 'Home Page (5:3)'
      fill_in 'Left', with: '1'
      fill_in 'Top', with: '2'
      fill_in 'Width', with: '500'
      fill_in 'Height', with: '300'
      click_button 'Add crop'

      fill_in 'Caption', with: 'Some caption'
      click_button 'Set caption'

      visit @magazine_url
      click_link 'Publish'

      page.should have_css('.alert-info', text: 'Story was successfully published')
    end
  end

  context 'Biography creation and publication' do

    before(:each) do
      create_valid_category(name: 'Biography', document_type: 'biography')

      visit root_path
      click_link 'New Biography'

      page.should_not have_select('Section')

      fill_in 'Title', with: 'John Doe'
      fill_in 'Subtitle', with: 'John Doe, a man of the people'
      fill_in 'Excerpt', with: 'John Doe was born in 1901'
      fill_in 'Body', with: "Last week would have been John Doe's birthday"

      click_button 'Save'

      page.should_not have_select('Secondary categories')

      @biography_url = current_url
      click_link 'Images'
      click_link 'Image rights'

      select 'Getty Images', from: 'Agency'
      fill_in 'Photographer', with: 'Helmut Newton'
      click_button 'Save'

      click_link 'All images'

      attach_file 'Add images', fixture_file('story_image.jpg')
      click_button 'Add images'
    end

    scenario 'Creating a Biography' do
      click_link 'All images'

      page.should_not have_css('.images .image_thumbnail .metadata', text: 'Full Size')
      page.should_not have_css('.images .image_thumbnail .metadata', text: 'Home Page (5:3)')
    end

    scenario 'Publishing a Biography' do
      click_link 'Biography'
      click_link 'Categorization'
      within 'form.categorisation' do
        fill_in 'People', with: 'Kate'
        click_button 'Save'
      end
      click_link 'Images'

      click_link 'All images'

      all('#images-list .media a')[0].click

      find('ul.crops').click_link 'Home Page (5:3)'
      fill_in 'Left', with: '1'
      fill_in 'Top', with: '2'
      fill_in 'Width', with: '500'
      fill_in 'Height', with: '300'
      click_button 'Add crop'

      fill_in 'Caption', with: 'Some caption'
      click_button 'Set caption'

      visit @biography_url
      click_link 'Publish'

      page.should have_css('.alert-info', text: 'Story was successfully published')
    end
  end

  context 'Album creation and publication' do

    before(:each) do
      create_valid_category(name: 'Album', document_type: 'album')
      PropertyType.create(story_type: 'Album', name: 'album_property')

      visit root_path
      click_link 'New Album'

      fill_in 'Title', with: 'HELLO! Album'
      fill_in 'Excerpt', with: 'First album'
      fill_in 'Body', with: 'First album'

      fill_in 'album_property', with: '1'

      click_button 'Save'

      @album_url = current_url
      click_link 'Images'

      click_link 'Image rights'

      select 'Getty Images', from: 'Agency'
      fill_in 'Photographer', with: 'Helmut Newton'
      click_button 'Save'

      click_link 'All images'
      attach_file 'Add images', fixture_file('story_image.jpg')
      click_button 'Add images'
    end

    scenario 'Publishing an Album' do
      click_link 'Album'
      click_link 'Categorization'

      within 'form.categorisation' do
        fill_in 'People', with: 'Kate'
        click_button 'Save'
      end

      click_button 'Save'
      click_link 'Images'

      click_link 'All images'

      all('#images-list .media a')[0].click

      find('ul.crops').click_link 'Home Page (5:3)'
      fill_in 'Left', with: '1'
      fill_in 'Top', with: '2'
      fill_in 'Width', with: '500'
      fill_in 'Height', with: '300'
      click_button 'Add crop'

      fill_in 'Caption', with: 'Some caption'
      click_button 'Set caption'

      visit @album_url
      click_link 'Publish'

      page.should have_css('.alert-info', text: 'Story was successfully published')
    end
  end

  context 'video links filtering' do
    it 'replaces unsecure brightcove video links for the secure ones' do
      @story.update_attributes(body: Story::UNSECURE_VIDEO_LINK_PREFIX)
      visit edit_story_path(@story)

      page.should have_css('#story_body', text: Story::SECURE_VIDEO_LINK_PREFIX)
    end
  end

end
