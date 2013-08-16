require 'spec_helper'

describe 'home page' do
  it 'welcomes the user' do
    visit '/'
    expect(page).to have_content('Listing elements')
  end
end

