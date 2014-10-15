require 'spec_helper'

describe Area do

  describe "(Duplication)" do

    it "can be duplicated" do
      area = create_valid_area

      duplicate = area.duplicate

      duplicate.should be_new_record
    end

    it "has a different name when it is duplicated" do
      area = create_valid_shared_area(name: 'Cinema sidebar')

      duplicate = area.duplicate

      duplicate.name.should_not == 'Cinema sidebar'
    end

    it "can be duplicated multiple times with distinct names" do
      area = create_valid_shared_area(name: 'Cinema sidebar')

      dup1 = area.duplicate
      dup1.save!

      dup2 = area.duplicate
      dup2.save!

      dup1.name.should_not == area.name
      dup2.name.should_not == area.name
      dup2.name.should_not == dup1.name
    end

    it "duplicates its content blocks, when duplicated" do
      area = create_valid_shared_area(name: 'Cinema sidebar')
      area.blocks << create_valid_block
      area.blocks << create_valid_block

      duplicate = area.duplicate

      duplicate.should have(2).blocks
      [duplicate.blocks - area.blocks].should_not be_empty
    end

  end

  describe "needs publishing" do
    before(:each) do
      @area = create_valid_shared_area(name: 'Area 1')
      @area.update_attribute(:changed_since_last_publication, false)
    end

    it "just after create" do
      area = create_valid_shared_area(name: 'New area')
      area.needs_publishing?.should == true
    end

    it "when area name changes" do
      @area.update_attribute(:name, 'Area changed')
      @area.needs_publishing?.should == true
    end

    it "when a block is added" do
      block = create_valid_block
      @area.blocks << block
      @area.needs_publishing?.should == true
    end
  end

  describe "#as_json" do
    before(:each) do
      @area = create_valid_shared_area(name: 'Cinema sidebar')
      @area.blocks << create_valid_block
      @area.blocks << create_valid_block
      disabled_block = create_valid_block
      disabled_block.disable!
      @area.blocks << disabled_block

      @area_as_json = @area.as_json
    end

    it "exposes its name" do
      @area_as_json[:name].should == @area.name
    end

    it "exposes links to its related blocks" do
      @area_as_json[:blocks].should == @area.blocks.enabled.map(&:id)
    end
  end

end
