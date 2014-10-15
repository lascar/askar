require 'spec_helper'

describe Publisher do
  describe '.publish_path' do
    it "includes the partitioned_name for category's page artifacts" do
      category = create_valid_category
      artifact = category.page

      StringUtils.any_instance.should_receive(:partitioned_name).with(artifact.slug).and_return("")

      path = Publisher.publish_path(artifact)
    end

    it "includes the partitioned_name for tag's page artifacts" do
      tag = create_valid_tag
      tag.create_associated_page
      artifact = tag.page

      StringUtils.any_instance.should_receive(:partitioned_name).with(artifact.slug).and_return("")

      path = Publisher.publish_path(artifact)
    end

    it "doesn't include the partitioned_name for crop artifacts" do
      story = create_valid_story
      image = create_valid_image
      image.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)
      story.images << image
      artifact = image.crops.first

      StringUtils.any_instance.should_not_receive(:partitioned_name)

      path = Publisher.publish_path(artifact)
    end

    it "includes the partitioned_name for biography documents" do
      artifact = create_valid_story(title: 'A title', story_type: "Biography")
      artifact.set_published_and_save

      StringUtils.any_instance.should_receive(:partitioned_name).with(artifact.title_slug).and_return("")

      path = Publisher.publish_path(artifact)
    end

    it "includes the magazines directory and the partitioned issue for magazines" do
      artifact = create_valid_story(title: 'A title', story_type: 'Magazine')
      artifact.should_receive(:get_property_value_by_type).with('issue').and_return(100)

      Publisher.should_receive(:partitioned).with(100).and_return('000/000/100')

      Publisher.publish_path(artifact, '').should == "/stories/magazines/000/000/100/#{Publisher::DATA_FILE_NAME}"
    end
  end

  describe '.partitioned' do
    it "partitions an integer into three slash separated parts" do
      Publisher.partitioned(1).should == "000/000/001"
      Publisher.partitioned(123456789).should == "123/456/789"
      Publisher.partitioned(12).should == "000/000/012"
      Publisher.partitioned(123).should == "000/000/123"
      Publisher.partitioned(1234).should == "000/001/234"
    end
  end

  describe ".artifact_data_parts" do

    it "returns a Crop's data parts keyed by partial path" do
      crop = double('Crop')
      crop.should_receive(:data_parts).and_return([{ path: 'crops/path1', data: "data1" }, { path: 'crops/path2', data: "data2" }])

      Publisher.artifact_data_parts(crop).should == [{ path: 'crops/path1', data: "data1" }, { path: 'crops/path2', data: "data2" }]
    end

    context "for a Story" do

      before(:each) do
        @story = double("Story")
        Publisher.should_receive(:partial_path).with(@story).and_return("/stories/42/data.json")
        @story.stub_chain(:as_json, :to_json).and_return( "data42" )
      end

      it "returns a single data part" do
        Publisher.artifact_data_parts(@story).size.should == 1
      end

      it "returns a single data part with the data being the story encoded to JSON" do
        Publisher.artifact_data_parts(@story)[0][:data].should == "data42"
      end

      it "returns a single data part with the path being the partial path of the Story" do
        Publisher.artifact_data_parts(@story)[0][:path].should == "/stories/42/data.json"
      end
    end
  end

  describe "write data public api" do
    let(:artifact) { Object.new }

    before(:each) do
      Publisher.stub(:write_data)
    end

    describe ".write_publish_data" do
      it "calls write_data with the configured publish targets" do
        Publisher.should_receive(:write_data).with(artifact, PUBLISH_CONFIG[:publish_targets])

        Publisher.write_publish_data(artifact)
      end
    end

    describe ".write_preview_data" do
      it "calls write_data with the configured preview targets" do
        Publisher.should_receive(:write_data).with(artifact, PUBLISH_CONFIG[:preview_targets])

        Publisher.write_preview_data(artifact)
      end
    end
  end

  describe ".write_data" do
    let(:artifact) { Object.new  }
    let(:path) { 'path' }
    let(:data_parts) {  [{ path: "/path1", data: "data1" }, { path: "/path2", data: "data2" }]}

    before(:each) do
      Publisher.stub(:write_local_data)
    end

    it "calls the method to write local data for each of the local targets" do
      local_target = { type: 'local', base_path: 'base_path' }
      config = [local_target]

      Publisher.should_receive(:artifact_data_parts).and_return(data_parts)
      Publisher.should_receive(:write_local_data).once.with('base_path/path1', 'data1')
      Publisher.should_receive(:write_local_data).once.with('base_path/path2', 'data2')

      Publisher.write_data(artifact, config)
    end

    it "always call write_local_data with the internal publication path" do
      config = []

      Publisher.should_receive(:artifact_data_parts).and_return(data_parts)
      Publisher.should_receive(:write_local_data).once.with('tmp/publish/path1', 'data1')
      Publisher.should_receive(:write_local_data).once.with('tmp/publish/path2', 'data2')

      Publisher.write_data(artifact, config)
    end

    it "only calls write_local_data with the internal publication path once although it is explicitly configured in publish.yml" do
      local_target = { type: 'local', base_path: Rails.configuration.internal_publication_path }
      config = [local_target]

      Publisher.should_receive(:artifact_data_parts).and_return(data_parts)
      Publisher.should_receive(:write_local_data).once.with("#{Rails.configuration.internal_publication_path}/path1", 'data1')
      Publisher.should_receive(:write_local_data).once.with("#{Rails.configuration.internal_publication_path}/path2", 'data2')

      Publisher.write_data(artifact, config)
    end

    it "does not crash if none target is given" do
      config = nil

      Publisher.should_receive(:artifact_data_parts).and_return(data_parts)
      Publisher.should_receive(:write_local_data).once.with("#{Rails.configuration.internal_publication_path}/path1", 'data1')
      Publisher.should_receive(:write_local_data).once.with("#{Rails.configuration.internal_publication_path}/path2", 'data2')

      Publisher.write_data(artifact, config)
    end
  end

  describe ".first_preview_path" do
    it "returns the first preview path in the configuration" do
      @back_publish_config = PUBLISH_CONFIG
      Object.const_redef(:PUBLISH_CONFIG, preview_targets: [base_path: 'path'])

      Publisher.first_preview_path.should == 'path'
      Object.const_redef(:PUBLISH_CONFIG, @back_publish_config)
    end

    it "returns the internal publication path if there are no preview paths in teh configuration" do
      @back_publish_config = PUBLISH_CONFIG
      Object.const_redef(:PUBLISH_CONFIG, preview_targets: nil)

      Publisher.first_preview_path.should == Rails.configuration.internal_publication_path
      Object.const_redef(:PUBLISH_CONFIG, @back_publish_config)
    end
  end

  describe ".first_publish_path" do
    it "returns the first publish path in the configuration" do
      @back_publish_config = PUBLISH_CONFIG
      Object.const_redef(:PUBLISH_CONFIG, publish_targets: [base_path: 'path'])

      Publisher.first_publish_path.should == 'path'
      Object.const_redef(:PUBLISH_CONFIG, @back_publish_config)
    end

    it "returns the internal publication path if there are no publish paths in teh configuration" do
      @back_publish_config = PUBLISH_CONFIG
      Object.const_redef(:PUBLISH_CONFIG, publish_targets: nil)

      Publisher.first_publish_path.should == Rails.configuration.internal_publication_path
      Object.const_redef(:PUBLISH_CONFIG, @back_publish_config)
    end
  end

  describe ".write_publish_summary" do
    let(:data) { %w(a b) }
    let(:path) { 'path' }

    before(:each) do
      @back_publish_config = PUBLISH_CONFIG
      Publisher.stub(:write_local_data)
      Time.stub_chain(:now, :to_f, :to_s).and_return 'timestamp'
    end

    after(:each) do
      Object.const_redef(:PUBLISH_CONFIG, @back_publish_config)
    end

    it "writes the list of file names given in a configured internal path" do
      Object.const_redef(:PUBLISH_CONFIG, summary_file_path: 'path')

      filename = File.join(PUBLISH_CONFIG[:summary_file_path], 'timestamp')
      Publisher.should_receive(:write_local_data).with(filename, data.join("\n"))

      Publisher.write_publish_summary(data)
    end

    it "writes to a predefined path if none is specified in the configuration" do
      Object.const_redef(:PUBLISH_CONFIG, {})

      filename = File.join(Rails.configuration.internal_publication_path + '/summary', 'timestamp')
      Publisher.should_receive(:write_local_data).with(filename, data.join("\n"))

      Publisher.write_publish_summary(data)
    end

    it "does not write repeated elements" do
      repeated_data = data.dup << data.first
      Object.const_redef(:PUBLISH_CONFIG, summary_file_path: 'path')
      filename = File.join(PUBLISH_CONFIG[:summary_file_path], 'timestamp')

      Publisher.should_receive(:write_local_data).with(filename, data.join("\n"))

      Publisher.write_publish_summary(repeated_data)
    end
  end
end
