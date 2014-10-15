require 'spec_helper'

describe Region do

  describe "#as_json" do

    before(:each) do
      @template = create_valid_template
      page = create_valid_page(template: @template)
      @region = page.regions.create! name: "A region"
    end

    it "exposes its name" do
      @region.as_json[:name].should == @region.name
    end

    it "exposes its area ids ordered" do
      area1 = create_valid_area
      area2 = create_valid_area
      @region.areas << area2
      @region.areas << area1

      area_ids = [area2.id, area1.id]

      @region.as_json[:areas].should == area_ids.as_json
    end

  end

  describe "#name_for_json" do
    it "returns the sym of the parameterized name without the initial number and appended with _region" do
      template = create_valid_template
      page = create_valid_page(template: template)
      region = page.regions.create! name: "1 - News Flow"

      region.name_for_json.should == :"news-flow-region"
    end
  end
end
