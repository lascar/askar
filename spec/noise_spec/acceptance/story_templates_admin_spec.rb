require 'spec_helper'

feature "story templates admin" do
  context "without admin role" do
    background do
      login_as('user')
    end

    scenario "doesn't see Admin > Story templates link" do
      visit root_path
      within '#settings-menu' do
        page.should_not have_css('li', text: "Story templates")
      end
    end

    scenario "can't access story templates listing" do
      visit story_templates_path
      current_path.should eq(root_path)
      page.should have_css('.alert-error', text: "Not authorized")
    end

    scenario "can't add new story template" do
      visit new_story_template_path
      current_path.should eq(root_path)
      page.should have_css('.alert-error', text: "Not authorized")
    end

    scenario "can't edit existing story template" do
      story_template = create_valid_story_template
      visit edit_story_template_path(story_template)
      current_path.should eq(root_path)
      page.should have_css('.alert-error', text: "Not authorized")
    end
  end

  context "with admin role" do
    background do
      login_as('user', 'admin')
    end

    scenario "sees Admin > Users link" do
      visit root_path
      within '#settings-menu' do
        page.should have_css('li', text: "Story templates")
      end
    end

    scenario "can access story templates listing" do
      visit story_templates_path
      page.should have_css('th', text: "Name")
      page.should have_css('th', text: "Filename")
    end

    scenario "can add new story template" do
      visit new_story_template_path

      fill_in 'Name', with: 'some_story_template'
      fill_in 'Filename', with: 'some_story_template.html'
      click_button 'Save'

      page.should have_css('td', text: 'some_story_template')
      page.should have_css('td', text: 'some_story_template.html')
    end

    scenario "can edit existing story template" do
      story_template = create_valid_story_template
      visit edit_story_template_path(story_template)

      fill_in 'Name', with: 'other_story_template'
      fill_in 'Filename', with: 'other_story_template.html'
      click_button 'Save'

      page.should have_css('td', text: 'other_story_template')
      page.should have_css('td', text: 'other_story_template.html')
    end
  end
end
