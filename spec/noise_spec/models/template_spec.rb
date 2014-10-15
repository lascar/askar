require 'spec_helper'

describe Template do
  describe "#as_json" do
    let(:template) { create_valid_template}
    let(:template_as_json) { template.as_json }
    
    it "exposes its id" do
      template_as_json[:id].should == template.id
    end
    
    it "exposes its name" do
      template_as_json[:name].should == template.name
    end
  end
end
