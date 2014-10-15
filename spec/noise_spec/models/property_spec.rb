require 'spec_helper'

describe Property do
  describe "#as_json" do
    before(:each) do
      @property_type_name = "News Story Property"
      property_type = create_valid_property_type(name: @property_type_name, story_type: "NewsStory")
      story = create_valid_story
      @property_value = "value"
      property = story.properties.first
      property.update_attribute(:value, @property_value)
      @property_as_json = property.as_json
    end
    
    it "exposes its value for the property_type" do
      @property_as_json[@property_type_name.downcase.tr(' ', '_').to_sym].should == @property_value
    end
  end
end
