# -*- coding: utf-8 -*-
require 'spec_helper'

describe PagePublisher do
  describe ".publish" do
    it "calls write_publish_summary with the paths of the published files" do
      page = double("Page")

      Publisher.stub(:write_publish_summary)
      PagePublisher.stub(:write)
      
      file_paths_array = %w(json_path crop_path)
      
      PagePublisher.should_receive(:get_files_array).and_return(file_paths_array)

      Publisher.should_receive(:write_publish_summary).with(file_paths_array)

      PagePublisher.publish(page)
    end
  end

  describe ".get_files_array" do
    it "returns an array with the internal paths of the published files" do
      page = create_valid_page
      area = create_valid_area
      region = page.regions.create! name: "A region"
      create_valid_container(area_id: area.id, region_id: region.id)
      
      Publisher.should_receive(:publish_path).with(page).and_return('page_json_path')
      files_array = %w(area_json_path block_json_path block_crop_path)
      AreaPublisher.should_receive(:get_files_array).with(area).and_return(files_array)

      PagePublisher.get_files_array(page).should == %w(page_json_path) + files_array
    end
  end
end
