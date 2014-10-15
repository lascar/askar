require "spec_helper"

feature "Images" do

  background do
    login_as('user', 'editor')

    @category = create_valid_category(name: 'Royalty')
    @story = create_valid_story(category: @category, title: "First story", creator: 'user')

    @image1 = create_valid_image(position: '1', caption: 'Secondary image')
    @image2 = create_valid_image(position: '2', caption: 'Primary image')

    @story.images = [@image1, @image2]
  end

  scenario "Viewing images as a mosaic" do
    visit root_path

    click_link "First story"
    click_link "Images"

    page.should have_css('#images-list .media', count: 2)
    page.should have_css('a', text: 'All images')
  end

  scenario "Adding images from the mosaic" do
    visit root_path

    click_link "First story"
    click_link "Images"

    attach_file "Add images", fixture_file("story_image.jpg")
    click_button "Add images"

    page.should have_css('.media', count: 3)

    attach_file "Add images", fixture_file("story_image.jpg")
    click_button "Add images"

    page.should have_css('.media', count: 4)
  end

  scenario "Deleting images" do
    visit root_path

    click_link "First story"
    click_link "Images"
    page.should have_css('#images-list .media', count: 2)

    first('#images-list .media').click_button 'Delete'

    page.should have_css('#images-list .media', count: 1)
  end

  scenario "Reorder images alphabetically" do

    filenames = ['test_img_2.jpg', 'test_img_6.jpg', 'test_img_4.jpg', 'test_img_5.jpg', 'test_img_3.jpg', 'test_img_1.jpg']
    images = []

    filenames.each_with_index do |filename, i|
      images << create_valid_image(position: i+1, caption: "image", attachment: fixture_file(filename))
    end
    @story.images = images

    visit root_path
    click_link "First story"
    click_link "Images"
    click_link "Gallery images"

    click_button "Reorder images alphabetically"

    image_source_filenames = page.all('#images-list .media img').map{|el| el[:src].split('/').last }
    image_source_filenames.should == filenames.sort
  end

  context "Editing multiple images" do

    background do
      visit root_path

      click_link "First story"
      click_link "Images"

      click_link "All images"
    end

    scenario "Add 'featured' Crops" do
      find('#images-list .media a').click

      find('ul.crops').click_link 'Home Page (5:3)'
      fill_in "Top", with: "20"
      fill_in "Left", with: "10"
      fill_in "Width", with: "500"
      fill_in "Height", with: "300"
      click_button "Add crop"

      page.should have_css('ul.crops a.done', text: 'Home Page (5:3)')
    end

    scenario "Add 'body' Crops" do
      find('#images-list .media a').click

      find('ul.crops').click_link 'Story Landscape (5:3)'
      fill_in "Top", with: "20"
      fill_in "Left", with: "10"
      fill_in "Width", with: "160"
      fill_in "Height", with: "90"
      click_button "Add crop"

      find('ul.crops').click_link 'Story Portrait (3:5)'
      fill_in "Top", with: "20"
      fill_in "Left", with: "10"
      fill_in "Width", with: "160"
      fill_in "Height", with: "90"
      click_button "Add crop"

      page.should have_css('ul.crops a.done', text: 'Story Landscape (5:3)')
      page.should have_css('ul.crops a.done', text: 'Story Portrait (3:5)')

    end

    scenario "Add 'gallery' Crops" do
      find('#images-list .media a').click

      find('ul.crops').click_link 'Gallery Landscape (5:3)'
      fill_in "Top", with: "20"
      fill_in "Left", with: "10"
      fill_in "Width", with: "160"
      fill_in "Height", with: "90"
      click_button "Add crop"

      find('ul.crops').click_link 'Gallery Portrait (3:5)'
      fill_in "Top", with: "20"
      fill_in "Left", with: "10"
      fill_in "Width", with: "160"
      fill_in "Height", with: "90"
      click_button "Add crop"

      page.should have_css('ul.crops a.done', text: 'Gallery Landscape (5:3)')
      page.should have_css('ul.crops a.done', text: 'Gallery Portrait (3:5)')

    end

    scenario "Edit existing crop" do
      find('#images-list .media a').click

      find('ul.crops').click_link 'Home Page (5:3)'
      fill_in "Top", with: "20"
      fill_in "Left", with: "10"
      fill_in "Width", with: "500"
      fill_in "Height", with: "300"
      click_button "Add crop"

      page.should have_css('ul.crops a.done', text: 'Home Page (5:3)')

      find('ul.crops').click_link 'Home Page (5:3)'
      fill_in "Top", with: "40"
      fill_in "Left", with: "40"
      fill_in "Width", with: "500"
      fill_in "Height", with: "500"
      click_button "Update crop"

      page.should have_css('ul.crops a.done', text: 'Home Page (5:3)')
    end

    scenario "Set Image caption" do
      all('#images-list .media a')[0].click
      fill_in 'Caption', with: 'Primary image'
      click_button 'Set caption'

      all('#images-list .media a')[1].click
      fill_in 'Caption', with: 'Secondary image'
      click_button 'Set caption'

      page.should have_css("#images-list .image[title='Primary image']")
      page.should have_css("#images-list .image[title='Secondary image']")

    end
  end

  scenario "Setting global image rights for a story" do
    visit root_path
    click_link "First story"
    click_link "Images"
    click_link "Image rights"

    within ".image_right_story form" do
      select "Getty Images", from: "Agency"
      fill_in "Photographer", with: "Helmut Newton"
      select "Europe", from: "Usage rights"
      select "Canada", from: "Usage rights"
      fill_in "Expiry Date", with: "2021-12-21"

      click_button "Save"

      page.should have_select "Agency", selected: "Getty Images"
      page.should have_field "Photographer", with: "Helmut Newton"
      page.should have_select "Usage rights", selected: ["Europe", "Canada"]
    end
  end

  scenario "Setting individual image rights" do
    @story.images = [@image1]

    visit root_path
    click_link "First story"
    click_link "Images"
    click_link "Image rights"

    within ".image_right_story form" do
      select "Getty Images", from: "Agency"
      fill_in "Photographer", with: "Helmut Newton"

      select "Europe", from: "Usage rights"
      select "Canada", from: "Usage rights"
      fill_in "Expiry Date", with: "2021-12-21"

      click_button "Save"
    end

    within ".image_right_story form" do
      page.should have_select "Agency", selected: "Getty Images"
      page.should have_field "Photographer", with: "Helmut Newton"
      page.should have_select "Usage rights", selected: ["Europe", "Canada"]
    end

  end
end
