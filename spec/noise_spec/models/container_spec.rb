require 'spec_helper'

describe Container do

  before(:each) do
    @page = create_valid_page(title: "Royalty", template_id: Template.default_category_template.id)
    @region = @page.regions.first
  end

  it "should be valid" do
    container = new_valid_container
    container.should be_valid
  end

  it "is invalid without a related region" do
    container = create_valid_container(region_id: @region.id)
    container.region_id = nil
    container.should_not be_valid
    container.should have(1).error_on(:region_id)
  end

  it "sets its position to the maximum position + 1, when created" do
    @page.containers.where(region_id: @region.id).create!
    @page.containers.where(region_id: @region.id).first.position.should == 1
    @page.containers.where(region_id: @region.id).create!
    @page.containers.where(region_id: @region.id).last.position.should == 2
  end


  describe "#destroy" do

    before(:each) do
      @region = create_valid_region
      @area = create_valid_area(shared: false)
      @region.areas << @area
      @area_container = @area.containers.first
    end

    context "for a shared area" do
      it "doesn't destroy the shared area" do
        shared_area = @area_container.area
        shared_area.update_attributes(shared: true)

        expect {
          @area_container.reload.destroy
        }.to change(Area, :count).by(0)
      end
    end

    context "for an exclusive area" do
      it "destroy the exlcusive area" do
        shared_area = @area_container.area
        shared_area.update_attributes(shared: false)

        expect {
          @area_container.reload.destroy
        }.to change(Area, :count).by(-1)
      end
    end

  end

end
