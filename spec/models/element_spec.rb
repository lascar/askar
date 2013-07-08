require 'spec_helper'
require 'element'

describe Element do

  it 'must have a name' do
    should_not be_valid
  end
  
  it 'responds to name' do
    should respond_to(:name)
  end
end

