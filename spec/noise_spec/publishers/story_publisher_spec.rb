require 'spec_helper'

describe StoryPublisher do
  let(:story) { double("Story") }
  let(:published_story) { double("Story") }

  before(:each) do
    story.stub(:set_published_and_save)
    story.stub(:published_version).and_return(published_story)
    StoryPublisher.stub(:write_files)
    StoryPublisher.stub(:write)
    Publisher.stub(:write_publish_summary)

  end

  describe ".publish" do
    before(:each) do
      SolrIndexManager.stub(:new, :add_document)
      StoryPublisher.stub(:get_files_array)
    end

    it "calls set_published_and_save on story" do
      story.should_receive(:set_published_and_save)
      StoryPublisher.publish(story)
    end

    context "indexation" do
      before(:each) do
        @back_publish_config = PUBLISH_CONFIG
      end
      after(:each) do
        Object.const_redef(:PUBLISH_CONFIG, @back_publish_config)
      end

      it "calls the Indexer with the story if the indexation is enabled" do
        Object.const_redef(:PUBLISH_CONFIG, index_enabled: true)
        indexer = double('SolrIndexManager')
        indexer.should_receive(:add_document).with(story)
        SolrIndexManager.should_receive(:new).and_return(indexer)

        StoryPublisher.publish(story)
      end

      it "does not call the Indexer with the story if the indexation is disabled" do
        Object.const_redef(:PUBLISH_CONFIG, index_enabled: false)

        SolrIndexManager.should_not_receive(:new)

        StoryPublisher.publish(story)
      end
    end

    it "calls write_publish_summary with the paths of the published files" do
      file_paths_array = %w(json_path crop_path)

      StoryPublisher.should_receive(:get_files_array).and_return(file_paths_array)

      Publisher.should_receive(:write_publish_summary).with(file_paths_array)

      StoryPublisher.publish(story)
    end

    it "calls get the published files array from the original version of the story" do
      StoryPublisher.should_receive(:get_files_array).with(story)

      StoryPublisher.publish(story)
    end
  end

  describe ".get_files_array" do
    it "returns an array with the internal paths of the published files" do
      Publisher.stub(:publish_path)

      crop = double("Crop")

      category_block = double("Block")
      tag_block = double("Block")

      category_block.should_receive(:suspended?).and_return(false)
      tag_block.should_receive(:suspended?).and_return(false)

      category_headline_source = double("HeadlineSource")
      category_headline_source.should_receive(:block).and_return(category_block)
      tag_headline_source = double("HeadlineSource")
      tag_headline_source.should_receive(:block).and_return(tag_block)

      published_story.stub_chain(:crops, :featured).and_return([crop])
      published_story.stub_chain(:crops, :full_size).and_return([crop])
      story.stub_chain(:crops, :gallery).and_return([crop])
      story.stub_chain(:crops, :body).and_return([crop])
      story.stub_chain(:crops, :full_size).and_return([crop])

      published_story.should_receive(:category_headline_sources).and_return([category_headline_source])
      published_story.should_receive(:tag_headline_sources).and_return([tag_headline_source])

      Publisher.should_receive(:publish_path).with(story).and_return('story_json_path')
      Publisher.should_receive(:data_part_publish_paths).exactly(5).times.with(crop).and_return(['story_crop_json_path'])

      files_array = %w(block_json_path block_crop_path)
      HeadlineBlockPublisher.should_receive(:get_files_array).with(category_block).and_return(files_array)
      HeadlineBlockPublisher.should_receive(:get_files_array).with(tag_block).and_return(files_array)

      StoryPublisher.get_files_array(story).should == %w(story_json_path
                                                         story_crop_json_path
                                                         story_crop_json_path
                                                         story_crop_json_path
                                                         story_crop_json_path
                                                         story_crop_json_path) +
        files_array + files_array
    end
  end
end
