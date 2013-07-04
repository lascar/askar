require 'spec_helper'
describe 'add, show, update and delete element' do
  before(:each) do
    Element.create!(:name => 'element 1')
  end

  it 'add an new element' do
    Element.count == 1
  end
end

