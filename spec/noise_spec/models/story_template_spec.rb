require 'spec_helper'

describe StoryTemplate do
  describe "#as_json" do
    let(:story_template) { create_valid_story_template }
    let(:story_template_as_json) { story_template.as_json } 

    it "exposes its name" do
      story_template_as_json[:name].should == story_template.name
    end

    it "exposes its filename" do
      story_template_as_json[:filename].should == story_template.filename
    end
  end
end
