require 'spec_helper'

describe HeadlineBlockPublisher do

  describe ".publish" do

    it "doesn't write summary by default" do
      block = double("Block")
      block.should_receive(:enabled?).once.and_return(true)
      HeadlineBlockPublisher.stub(:write)

      Publisher.should_not_receive(:write_publish_summary)

      HeadlineBlockPublisher.publish(block)
    end

    it "doesn't publish disabled blocks" do
      block = double("Block")
      block.should_receive(:enabled?).once.and_return(false)

      HeadlineBlockPublisher.should_not_receive(:write)
      Publisher.should_not_receive(:write_publish_summary)

      HeadlineBlockPublisher.publish(block, write_summary: true)
    end

    it "calls write_publish_summary with the paths of the published files if instructed to do so" do
      block = double("Block")
      block.should_receive(:enabled?).once.and_return(true)

      Publisher.stub(:write_publish_summary)
      HeadlineBlockPublisher.stub(:write)

      file_paths_array = %w(json_path crop_path)
      HeadlineBlockPublisher.should_receive(:get_files_array).with(block).and_return(file_paths_array)

      Publisher.should_receive(:write_publish_summary).with(file_paths_array)

      HeadlineBlockPublisher.publish(block, write_summary: true)
    end
  end

  describe ".get_files_array" do

    it "returns an array with the internal paths of the published files" do
      block = create_valid_headline_block

      Headline.any_instance.should_receive(:linked).once.and_return(false)

      Publisher.should_receive(:publish_path).with(block).once.and_return('json_path')
      # FIXME Mocking this especially with this with() is brittle
      Publisher.should_receive(:data_part_publish_paths).with(block.headlines(true).first.crops.featured.first).and_return(['crop_path', 'thumb_crop_path'])

      HeadlineBlockPublisher.get_files_array(block).should == %w(json_path crop_path thumb_crop_path)
    end

    it "does not include the headline crops for linked headlines" do
      block = create_valid_headline_block
      Headline.any_instance.should_receive(:linked).once.and_return(true)

      Publisher.should_receive(:publish_path).with(block).once.and_return('json_path')
      Publisher.should_not_receive(:publish_path).with(block.headlines(true).first.story.images.featured.first.crops.first)

      HeadlineBlockPublisher.get_files_array(block).should == %w(json_path)
    end

    it "only returns full_size crops for a standalone block" do
      block = create_valid_block(content_type: "standalone")

      headline = create_valid_headline
      headline.image = create_valid_image
      headline.save!

      block.headlines << headline
      block.reload

      Publisher.should_receive(:publish_path).with(block).once.and_return('json_path')
      Publisher.should_receive(:data_part_publish_paths).with(headline.crops.full_size.first).once.and_return(['full_size_crop_path'])

      HeadlineBlockPublisher.get_files_array(block).should include('full_size_crop_path')
    end

    it "only returns full_size crops for a magazine headline in a standalone block" do
      block = create_valid_block(content_type: "standalone")
      magazine = create_published_story(story_type: "Magazine")

      headline = create_valid_headline(story: magazine)
      headline.image = create_valid_image
      headline.save!

      block.headlines << headline
      block.reload

      Publisher.should_receive(:publish_path).with(block).once.and_return('json_path')
      Publisher.should_receive(:data_part_publish_paths).with(headline.crops.full_size.first).once.and_return(['full_size_crop_path'])

      HeadlineBlockPublisher.get_files_array(block).should include('full_size_crop_path')

    end

    it "only returns full_size crops for a magazine headline in a headline block" do
      block = create_valid_block(content_type: "headlines")
      magazine = create_published_story(story_type: "Magazine")

      headline = create_valid_headline(story: magazine)
      headline.image = create_valid_image
      headline.save!

      block.headlines << headline
      block.reload

      Publisher.should_receive(:publish_path).with(block).once.and_return('json_path')
      Publisher.should_receive(:data_part_publish_paths).with(headline.crops.full_size.first).once.and_return(['full_size_crop_path'])

      HeadlineBlockPublisher.get_files_array(block).should include('full_size_crop_path')

    end

  end

end
