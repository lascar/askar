require 'spec_helper'

feature 'Related Stories' do

  background do
    login_as('user')

    @royalty = create_valid_category(name: 'Royalty')
    @general = create_valid_category(name: 'General')

    @story = create_valid_story(category: @royalty)
  end

  scenario 'add related stories' do
    @related_story = create_published_story(category: @general,
                                            title: 'general_story')

    visit edit_story_path(@story)
    click_link 'Related Stories'

    fill_in 'Search for',   with: 'general_story'
    click_button 'Search'

    within '#search-results' do
      page.should have_css('td', text: 'general_story')

      check("relatable_story_ids_#{@related_story.published_version.id}")
      click_button 'Add'
    end

    within '#related-stories' do
      page.should have_css('.headline div.media-heading', text: 'general_story')
    end
  end

  scenario 'remove related stories' do
    @related_story = create_published_story(category: @general,
                                            title: 'general_story')
    @story.headlines.create(story: @related_story, linked: true)

    visit edit_story_path(@story)
    click_link 'Related Stories'

    within '#related-stories' do
      # find_headline('general_story').
      click_button 'Delete'
    end

    page.should_not have_css('#related-stories .headline div.media-heading',
                             text: 'general_story')

  end

  scenario 'search normal stories in related stories finder' do
    create_published_story(category: @general, title: 'general_story')

    visit edit_story_path(@story)
    click_link 'Related Stories'

    fill_in 'Search for',   with: 'general_story'

    click_button 'Search'

    page.should have_css('td', text: 'general_story')
  end

  scenario 'search related stories in related stories finder' do
    @related_story = create_published_story(category: @general,
                                            title: 'general_story')
    @story.headlines.create(story: @related_story, linked: true)

    visit edit_story_path(@story)
    click_link 'Related Stories'

    fill_in 'Search for',   with: 'general_story'

    click_button 'Search'

    within :css, '#search-results' do
      page.should_not have_css('.headline div.media-heading',
                               text: 'general_story')
    end
  end

  scenario 'add external related story' do
    visit edit_story_path(@story)
    click_link 'Related Stories'

    title = 'Zombies from outer space'
    click_link 'Add external headline'

    fill_in 'Title', with: title
    fill_in 'Excerpt', with: 'More alien zombies, xenophobia rises'
    fill_in 'Url', with: 'http://www.example.com'

    click_button 'Save'

    within '#related-stories' do
      page.should_not have_css('.headline div.media-heading', text: 'title')
    end
  end

  scenario 'edit external related story', type: :acceptance do
    @story.headlines.create!(title: 'Some very interesting news',
                             linked: false, url: '/')

    visit edit_story_path(@story)
    click_link 'Related Stories'

    find_headline('Some very interesting news').click_link 'Edit Headline'

    fill_in 'Title', with: 'Zombies from outer space'
    fill_in 'Url', with: 'http://www.example.com'

    click_button 'Save'

    within '#related-stories' do
      page.should have_css('.headline div.media-heading',
                           text: 'Zombies from outer space')
    end
  end

end
