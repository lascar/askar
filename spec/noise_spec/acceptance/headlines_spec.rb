require 'spec_helper'

feature 'Headlines' do

  background do
    login_as('user', 'editor')
    @category = create_valid_category(name: 'Royalty')
    @category.update_attribute(:created_by_user, true)
    @page = @category.page
  end

  shared_examples 'standalone headlines' do

    background do
      MiniExiftool.unstub(:new)
    end

    scenario 'creating' do
      within('.block .panel-header') { click_link 'Add Headline' }
      fill_in 'Title', with: 'New headline'
      fill_in 'Excerpt', with: 'Wadus wadus'
      fill_in :headline_url, with: 'http://example.com'

      click_button 'Save'

      page.should have_css('.alert-info',
                           text: 'Headline was successfully created')
      page.should have_css('.headline', text: 'New headline')
    end

    scenario 'attaching image w/ EXIF rights' do
      find_headline('First headline').click_link 'Edit Headline'

      click_link 'Add image'

      within('#new_attachable') do
        attach_file 'Attachment', fixture_file('image_with_exif.jpg')
        click_button 'Save'
      end

      page.should have_css('.alert-info',
                           text: 'Image was successfully created')

      click_link 'Edit image'

      within('#edit_attachable') do
        page.should have_select('Agency', selected: 'Twitter')
        page.should have_field('Photographer', with: 'Helmut Newton')
      end
    end

    scenario 'attaching image w/ EXIF rights, user provides rights' do
      find_headline('First headline').click_link 'Edit Headline'
      click_link 'Add image'

      within('#new_attachable') do
        attach_file 'Attachment', fixture_file('image_with_exif.jpg')
        select 'Instagram', from: 'Agency'
        click_button 'Save'
      end

      page.should have_css('.alert-info',
                           text: 'Image was successfully created')

      click_link 'Edit image'

      within('#edit_attachable') do
        page.should have_select('Agency', selected: 'Instagram')
      end
    end

    scenario 'attaching image w/ out EXIF rights' do
      find_headline('First headline').click_link 'Edit Headline'
      click_link 'Add image'

      within('#new_attachable') do
        attach_file 'Attachment', fixture_file('image_without_exif.jpg')
        click_button 'Save'
      end

      page.should have_css('.alert-error', text: "Agency can't be blank")
    end

    scenario 'attaching image w/ out EXIF, user provides rights' do
      find_headline('First headline').click_link 'Edit Headline'
      click_link 'Add image'

      within('#new_attachable') do
        attach_file 'Attachment', fixture_file('image_without_exif.jpg')
        select 'Twitter', from: 'Agency'
        click_button 'Save'
      end

      page.should have_css('.alert-info',
                           text: 'Image was successfully created')

      click_link 'Edit image'

      within('#edit_attachable') do
        page.should have_select('Agency', selected: 'Twitter')
      end
    end

    scenario 'editing headline' do
      find_headline('First headline').click_link 'Edit Headline'

      within('form.edit_headline') do
        fill_in 'Title', with: 'UPDATED first headline'
        fill_in 'Url', with: 'http://updated.com'
        fill_in 'Excerpt', with: 'Wadus wadus'
        fill_in 'Secondary Url', with: 'http://updated.com/secondary'

        click_button 'Save'
      end

      page.should have_css('.alert-info',
                           text: 'Headline was successfully updated')

      page.should_not have_css('.headline', text: 'First headline')
      page.should have_css('.headline', text: 'UPDATED first headline')

      find_headline('UPDATED first headline').click_link 'Edit Headline'
      within('form.edit_headline') do
        page.should have_field('Title', with: 'UPDATED first headline')
        page.should have_field('Excerpt', with: 'Wadus wadus')
        page.should have_field('Url', with: 'http://updated.com')
        page.should have_field('Secondary Url', with: 'http://updated.com/secondary')
      end
    end

    scenario 'editing headline image' do
      @headline.image = create_valid_image(
        attachment: fixture_file('image_with_exif.jpg'),
        agency: nil,
        author: nil
      )
      @headline.save!

      find_headline('First headline').click_link 'Edit Headline'
      click_link 'Edit image'

      within('form.edit_attachable') do
        page.should have_select('Agency', selected: 'Twitter')
        page.should have_field('Photographer', with: 'Helmut Newton')

        select 'Instagram', from: 'Agency'
        fill_in 'Photographer', with: 'Someone'

        click_button 'Save'
      end

      page.should have_css('.alert-info',
                           text: 'Image was successfully updated')

      click_link 'Edit image'

      within('form.edit_attachable') do
        page.should have_select('Agency', selected: 'Instagram')
        page.should have_field('Photographer', with: 'Someone')
      end
    end

    scenario 'editing headline image, removing rights' do
      @headline.image = create_valid_image(
        attachment: fixture_file('image_without_exif.jpg'),
        agency: 'twitter',
        author: 'Helmut Newton'
      )
      @headline.save!

      find_headline('First headline').click_link 'Edit Headline'
      click_link 'Edit image'

      within('form.edit_attachable') do
        page.should have_select('Agency', selected: 'Twitter')

        select '', from: 'Agency'

        click_button 'Save'
      end

      page.should have_css('.alert-error', text: "Agency can't be blank")
    end

    scenario 'changing headline image' do
      @headline.image = create_valid_image(
        attachment: fixture_file('image_with_exif.jpg'),
        agency: nil,
        author: nil
      )
      @headline.save!

      find_headline('First headline').click_link 'Edit Headline'

      click_link 'Replace image'

      within('#new_attachable') do
        attach_file 'Attachment', fixture_file('image_with_exif.jpg')
        click_button 'Save'
      end

      click_link 'Edit image'

      within('form.edit_attachable') do
        page.should have_select('Agency', selected: 'Twitter')
        page.should have_field('Photographer', with: 'Helmut Newton')
      end
    end

    scenario 'deleting' do
      page.should have_css('.headline', text: 'First headline')

      find_headline('First headline').click_button 'Delete'
      page.should_not have_css('.headline', text: 'First headline')
    end

    scenario 'pinning' do
      page.should have_css('.headline.pinned', count: 2)

      find('.headline', text: 'First headline').click_link('Pin')

      page.should have_css('.headline.pinned', text: 'First headline')
      page.should have_css('.headline.pinned', count: 3)

      find('.headline', text: 'Third headline').click_link('Pin')

      page.should have_css('.headline.pinned', text: 'First headline')
      page.should have_css('.headline.pinned', text: 'Third headline')
      page.should have_css('.headline.pinned', count: 4)
    end

    scenario 'unpinning' do
      page.should have_css('.headline.pinned', count: 2)

      find('.headline', text: 'Second pinned headline').click_link('Unpin')

      page.should have_css('.headline.pinned', count: 1)
      page.should have_css('.headline.pinned', text: 'First pinned headline')
      page.should_not have_css('.headline.pinned',
                               text: 'Second pinned headline')
    end

    scenario 'cropping headline image' do
      @headline.image = create_valid_image(
        attachment: fixture_file('image_with_exif.jpg'))
      @headline.save!

      find_headline('First headline').click_link 'Edit Headline'

      click_link 'Edit image'
      page.should have_selector('#crops-list',
                                text: 'Full Size Home Page (5:3)')
      image_crops = []
      crops_exist = []
      @headline.image.crops.each do |crop|
        path = Publisher.publish_path(crop)
        crops_exist << File.exist?(path)
        image_crops << File.basename(path)
      end
      image_crops.flatten.sort.should eql(['featured_5_3.jpg', 'full_size.jpg'])
      crops_exist.should == [true, true]
    end
  end

  context 'in a page' do

    background do
      @area = create_valid_area(name: nil)
      @block = create_valid_block
      @area.blocks << @block
      @page.regions.first.areas << @area
    end

    it_behaves_like 'standalone headlines' do
      background do
        @headline = create_valid_headline(title: 'First headline')
        @block.headlines << @headline
        @block.headlines << create_valid_headline(title: 'Second headline')
        @block.headlines << create_valid_headline(title: 'Third headline')
        @block.headlines << create_valid_headline(
          title: 'First pinned headline', position: 1)
        @block.headlines << create_valid_headline(
          title: 'Second pinned headline', position: 2)

        visit root_path

        click_link 'Pages'
        click_link 'Royalty'

      end
    end

    context 'linked headline' do

      background do
        @story = create_published_story(title: 'Top story of the day')

        @headline = Headline.new(linked: true, story: @story)
        @headline.container = @block
        @headline.save!
      end

      scenario 'unlinks when edited' do
        visit root_path
        click_link 'Pages'
        click_link 'Royalty'

        page.should have_css('.headline.linked', text: 'Top story of the day')
        find('.headline.linked').click_link 'Edit Headline'

        visit root_path
        click_link 'Pages'
        click_link 'Royalty'

        page.should_not have_css('.headline.linked',
                                 text: 'Top story of the day')
        find_headline('Top story of the day').click_link 'Edit Headline'

        within('form.edit_headline') do
          page.should have_xpath("//img[@alt='Story_image']")
        end
      end
    end

    scenario 'No headlines from shared area' do
      @shared_area = create_valid_shared_area(name: 'Sidebar')
      @block2 = create_valid_block
      @shared_area.blocks << @block2
      @page.regions.first.areas << @shared_area
      @block2.headlines << create_valid_headline(title: 'First shared headline')
      @block2.headlines << create_valid_headline(
        title: 'Second shared headline')

      visit root_path

      click_link 'Pages'
      click_link 'Royalty'

      page.should have_css('button', text: 'Unlink')
      page.should have_text('Shared area: Sidebar')

      page.should_not have_css('.headline', 'First shared headline')
      page.should_not have_css('.headline', 'Second shared headline')
    end
  end

  context 'in a shared area' do

    background do
      @area = create_valid_shared_area(name: 'Latest news sidebar')
      @block = create_valid_block
      @area.blocks << @block
    end

    it_behaves_like 'standalone headlines' do
      background do
        @headline = create_valid_headline(title: 'First headline')
        @block.headlines << @headline
        @block.headlines << create_valid_headline(title: 'Second headline')
        @block.headlines << create_valid_headline(title: 'Third headline')
        @block.headlines << create_valid_headline(
          title: 'First pinned headline', position: 3)
        @block.headlines << create_valid_headline(
          title: 'Second pinned headline', position: 2)

        visit root_path

        click_link 'Edit Shared Areas'
        click_link 'Latest news sidebar'
      end
    end
  end

  context 'in a shared block' do

    background do
      @block = create_valid_shared_block(name: 'Latest news block')
    end

    it_behaves_like 'standalone headlines' do
      background do
        @headline = create_valid_headline(title: 'First headline')
        @block.headlines << @headline
        @block.headlines << create_valid_headline(title: 'Second headline')
        @block.headlines << create_valid_headline(title: 'Third headline')
        @block.headlines << create_valid_headline(
          title: 'First pinned headline', position: 3)
        @block.headlines << create_valid_headline(
          title: 'Second pinned headline', position: 2)

        visit root_path

        click_link 'Edit Shared Blocks'
        click_link 'Latest news block'
      end
    end
  end
end
