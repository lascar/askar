require 'spec_helper'

describe Crop do

  it "has an aspect ratio derived from its usage" do
    crop1 = Crop.create!(usage: "gallery:5:3",
                           top: 0, left: 0, width: 42, height: 43)
    crop2 = Crop.create!(usage: "gallery:3:5",
                           top: 0, left: 0, width: 42, height: 43)

    crop1.aspect_ratio.should == [5, 3]
    crop2.aspect_ratio.should == [3, 5]
  end

  context "usage" do

    it "can be a featured crop" do
      crop = Crop.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)
      crop.should be_featured
    end

    it "is unique for the same image" do
      image = create_valid_image
      image.crops.create!(usage: "gallery:5:3", top: 0, left: 0, width: 320, height: 480)
      crop = image.crops.build(usage: "gallery:5:3", top: 0, left: 0, width: 320, height: 480)
      crop.should_not be_valid
      crop.should have(1).error_on(:usage)
    end
  end

  describe ".usage_choices" do

    it "contains 8 distinct usages" do
      Crop.usage_choices.size.should == 8
    end

    it "contains gallery:5:3" do
      Crop.usage_choices.rassoc('gallery:5:3').should_not be_empty
    end

    it "contains gallery:3:5" do
      Crop.usage_choices.rassoc('gallery:3:5').should_not be_empty
    end

    it "contains body:1:1" do
      Crop.usage_choices.rassoc('body:1:1').should_not be_empty
    end

    it "contains body:5:3" do
      Crop.usage_choices.rassoc('body:5:3').should_not be_empty
    end

    it "contains body:5:3" do
      Crop.usage_choices.rassoc('body:5:3').should_not be_empty
    end

    it "contains full_size" do
      Crop.usage_choices.rassoc('full_size').should_not be_empty
    end

    it "contains featured:5:3" do
      Crop.usage_choices.rassoc('featured:5:3').should_not be_empty
    end

    it "contains video:16:9" do
      Crop.usage_choices.rassoc('video:16:9').should_not be_empty
    end

  end

  describe "scopes" do

    before(:each) do
      create_valid_crop(usage: "featured:5:3")
      create_valid_crop(usage: "gallery:5:3")
      create_valid_crop(usage: "gallery:3:5")
      create_valid_crop(usage: "body:1:1")
      create_valid_crop(usage: "body:5:3")
      create_valid_crop(usage: "body:3:5")
      create_valid_crop(usage: "video:16:9")
    end

    describe ".featured" do
      it "returns all featured crops" do
        Crop.featured.collect(&:usage).sort.should == ['featured:5:3']
      end
    end

    describe ".body" do
      it "returns all body crops" do
        Crop.body.collect(&:usage).sort.should == ['body:1:1', 'body:3:5', 'body:5:3']
      end
    end

    describe ".gallery" do
      it "returns all gallery crops" do
        Crop.gallery.collect(&:usage).sort.should == ['gallery:3:5', 'gallery:5:3']
      end
    end
  end

  context "A story" do

    before(:each) do
      @story = create_valid_story
      @image1 = create_valid_image
      @image2 = create_valid_image
      @story.images = [@image1, @image2]
    end

    it "should have only one featued crop" do
      crop1 = @image1.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)
      @story.crops.featured.should == [crop1]

      crop2 = @image2.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 500, height: 300)
      @story.crops.featured.should include(crop2)
      @story.crops.featured.should_not include(crop1)
    end

    it "[ISSUE #454] can have 2 body and 2 gallery crops per image" do

      crop1 = @image1.crops.create!(usage: "gallery:5:3",
                           top: 0, left: 0, width: 42, height: 43)
      crop2 = @image1.crops.create!(usage: "gallery:3:5",
                           top: 0, left: 0, width: 42, height: 43)
      crop3 = @image1.crops.create!(usage: "body:5:3",
                           top: 0, left: 0, width: 42, height: 43)
      crop4 = @image1.crops.create!(usage: "body:3:5",
                           top: 0, left: 0, width: 42, height: 43)


      crop5 = @image2.crops.create!(usage: "gallery:5:3",
                           top: 0, left: 0, width: 42, height: 43)
      crop6 = @image2.crops.create!(usage: "gallery:3:5",
                           top: 0, left: 0, width: 42, height: 43)
      crop7 = @image2.crops.create!(usage: "body:5:3",
                           top: 0, left: 0, width: 42, height: 43)
      crop8 = @image2.crops.create!(usage: "body:3:5",
                           top: 0, left: 0, width: 42, height: 43)

      @image1.reload.crops.sort.should == [crop1, crop2, crop3, crop4].sort
      @image2.reload.crops.sort.should == [crop5,crop6 ,crop7, crop8].sort
    end
  end

  describe "#path" do
    before(:each) do
      @story = create_valid_story
      id = "%09d" % @story.id
      @partitioned_story_id = File.join(id[0..2],id[3..5],id[6..9])
      @image = create_valid_image
      @story.images = [@image]
      @usage = "featured:5:3"
      @crop = @image.crops.create!(usage: @usage, top: 0, left: 0, width: 50, height: 30)
    end

    it "returns the path of the crop" do
      story = create_valid_story
      image = create_valid_image
      story.images = [image]
      usage = "featured:5:3"
      crop = image.crops.create!(usage: usage, top: 0, left: 0, width: 50, height: 30)
      created_at = story.created_at

      Publisher.should_receive(:partitioned).with(crop.id).and_return('path')

      crop.path.should == File.join("%02d" % created_at.year.to_s,
                                    "%02d" % created_at.month.to_s,
                                    "%02d" % created_at.day.to_s,
                                    'path',
                                    "#{usage.gsub(':', '_')}.#{image.attachment.ext}")
    end
  end

  describe "#as_json" do
    before(:each) do
      story = create_valid_story
      @image = create_valid_image(caption: "Image caption")
      story.images = [@image]
      @usage = "featured:5:3"
      @crop = @image.crops.create!(usage: @usage, top: 0, left: 0, width: 50, height: 30)

      @crop.height = @crop.width =100

      @crop_as_json = @crop.as_json
    end

    it "exposes its caption" do
      @crop_as_json[:caption].should == @image.caption
    end

    it "exposes its usage" do
      @crop_as_json[:usage].should == @usage
    end

    it "exposes its path" do
      @crop_as_json[:path].should == @crop.path
    end

    it "exposes its dimensions" do
      @crop_as_json[:height].should == @crop.height
      @crop_as_json[:width].should == @crop.width
    end

    it "exposes a thumb_path for full_size crops" do
      @crop.update_attributes(usage: "full_size")
      @crop.as_json[:thumb_path].should be_present
    end

    it "exposes a thumb_path for featured:5:3 crops" do
      @crop.update_attributes(usage: "featured:5:3")
      @crop.as_json[:thumb_path].should be_present
    end

    it "exposes its image's rights" do
      expires_at = 1.week.from_now
      @crop.image.stub(:rights_as_json).and_return({agency: "rex", author: "unknown", expires_at: expires_at, usage_rights: ["worldwide"] })

      @crop.as_json[:rights].should be_present
      @crop.as_json[:rights][:agency].should == "rex"
      @crop.as_json[:rights][:author].should == "unknown"
      @crop.as_json[:rights][:expires_at].should == expires_at
      @crop.as_json[:rights][:usage_rights].should == ["worldwide"]
    end

  end

  describe "#crop_to_aspec_ratio!" do
    before(:each) do
      @crop = Crop.create!(usage: "gallery:5:3", top: 0, left: 0, width: 500, height: 300)
    end

    describe "image aspect ratio > crop aspect ratio" do
      before(:each) do
        @crop.stub!(:image_width).and_return(60)
        @crop.stub!(:image_height).and_return(30)
        @crop.crop_to_aspect_ratio!
      end

      it "sets top,left to 0,0" do
        @crop.top.should == 0
        @crop.left.should == 0
      end

      it "crop the original image width" do
        @crop.width.should == 50
      end

      it "maintains the original image height" do
        @crop.height.should == 30
      end

      it "matches the required crop ratio" do
        (@crop.width/@crop.height.to_f).should == 5/3.0
      end

    end

    describe "image aspect ratio < crop aspect ratio" do
      before(:each) do
        @crop.stub!(:image_width).and_return(60)
        @crop.stub!(:image_height).and_return(100)
        @crop.crop_to_aspect_ratio!
      end

      it "sets top,left to 0,0" do
        @crop.top.should == 0
        @crop.left.should == 0
      end

      it "maintains the original image width" do
        @crop.width.should == 60
      end

      it "crop the original image height" do
        @crop.height.should == 36
      end

      it "matches the required crop ratio" do
        (@crop.width/@crop.height.to_f).should == 5/3.0
      end
    end

  end

  describe "#duplicate" do
    before(:each) do
      @crop = Crop.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height:30)
    end

    it "duplicates the usage" do
      @duplicate = @crop.duplicate
      @duplicate.save!

      @duplicate.usage.should == "featured:5:3"
    end

    it "duplicates the dimensions" do
      @duplicate = @crop.duplicate
      @duplicate.save!

      @duplicate.top.should == 0
      @duplicate.left.should == 0
      @duplicate.width.should == 50
      @duplicate.height.should == 30
    end

  end

  describe "#has_thumbnail?" do

    it "is true for featured crops" do
      @crop = Crop.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height:30)
      @crop.should have_thumbnail
    end

    it "is false for landscape gallery crops" do
      @crop = Crop.create!(usage: "gallery:5:3", top: 0, left: 0, width: 50, height:30)
      @crop.should_not have_thumbnail
    end

    it "is true for portrait gallery crops" do
      @crop = Crop.create!(usage: "gallery:3:5", top: 0, left: 0, width: 50, height:30)
      @crop.should have_thumbnail
    end

    it "is true for full size crops" do
      @crop = Crop.create!(usage: "full_size", top: 0, left: 0, width: 50, height:30)
      @crop.should have_thumbnail
    end

  end
end
