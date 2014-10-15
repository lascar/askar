# -*- coding: utf-8 -*-
require 'spec_helper'

describe AreaPublisher do
  describe ".publish" do
    it "doesn't write summary by default" do
      AreaPublisher.stub(:write)

      Publisher.should_not_receive(:write_publish_summary)

      AreaPublisher.publish(double("Area"))
    end

    it "calls write_publish_summary with the paths of the published files" do
      area = double("Area")

      Publisher.stub(:write_publish_summary)
      AreaPublisher.stub(:write)
      
      file_paths_array = %w(json_path crop_path)
      
      AreaPublisher.should_receive(:get_files_array).and_return(file_paths_array)

      Publisher.should_receive(:write_publish_summary).with(file_paths_array)

      AreaPublisher.publish(area, write_summary: true)
    end
  end

  describe ".get_files_array" do
    it "returns an array with the internal paths of the published files" do
      block = create_valid_headline_block
      area = create_valid_area
      area.blocks << block
      
      Publisher.should_receive(:publish_path).with(area).and_return('area_json_path')
      files_array = %w(block_json_path block_crop_path)
      HeadlineBlockPublisher.should_receive(:get_files_array).with(block).and_return(files_array)

      AreaPublisher.get_files_array(area).should == %w(area_json_path) + files_array
    end
  end
end
