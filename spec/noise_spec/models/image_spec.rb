require 'spec_helper'

describe Image do

  context "for a story" do
    before(:each) do
      @story = create_valid_story
      @story.images = []
    end

    it "sets its position to the maximum position + 1, when created" do
      @story.images.create!(attachment: fixture_file('story_image.jpg'))
      @story.images.first.position.should == 1
      @story.images.create!(attachment: fixture_file('story_image.jpg'))
      @story.images.last.position.should == 2
    end

  end

  describe "EXIF data extraction on creation" do
    it "creates an image right with EXIF data from attached image" do
      @image = create_valid_image(attachment: fixture_file('image_with_exif.jpg'))

      @image.author.should == "Helmut Newton"
      @image.agency.should == "gettyimages"
    end
  end

  describe "#exif_metadata" do
    it "returns EXIF metadata as a hash" do
      MiniExiftool.unstub(:new)

      @image = create_valid_image(attachment: fixture_file('image_with_exif.jpg'))
      @image.exif_metadata.should_not be_empty
      @image.exif_metadata["Copyright"].should == "Twitter"
      @image.exif_metadata["Artist"].should == "Helmut Newton"
    end
  end

  describe "#crops" do

    context "when attachable#requires_full_size_crop?" do
      before(:each) do
        attachable = mock_model(Story)
        attachable.stub!(:requires_full_size_crop?).and_return(true)
        attachable.stub!(:provides_image_rights?).and_return(true)
        @image = create_valid_image(attachment: fixture_file('story_image.jpg'), attachable: attachable)
      end

      it "creates a full_size crop" do
        @image.crops.full_size.size.should be(1)

        crop = @image.crops.full_size.first
        crop.top.should    == 0
        crop.left.should   == 0
        crop.width.should  == 160
        crop.height.should == 90
      end

      it "updates its full_size crop when it is updated" do

        @image.attachment = fixture_file('test_img_1.jpg')
        @image.save!

        @image.crops.full_size.size.should be(1)

        crop = @image.crops.full_size.first
        crop.top.should    == 0
        crop.left.should   == 0
        crop.width.should  == 800
        crop.height.should == 600

      end

      it "updates all featured crops when the attachment changes" do
        # Ugly, but necessary until we refactor crops and images
        @image.attachment = fixture_file('test_img_1.jpg')

        crop = @image.crops.featured.build
        crop.crop_to_aspect_ratio!
        crop.save!

        Crop.any_instance.should_receive(:crop_to_aspect_ratio!)

        @image.attachment = fixture_file('test_img_2.jpg')
        @image.save!

      end
    end

    context "when its attachable doesn't requires_full_size_crop?" do
      it "doesn't create a full_size crop when created" do
        attachable = mock_model(Story)
        attachable.stub!(:requires_full_size_crop?).and_return(false)
        attachable.stub!(:provides_image_rights?).and_return(true)
        @image = create_valid_image(attachment: fixture_file('story_image.jpg'), attachable: attachable)

      end
    end

    it "destroys any crops when destroyed" do
      @image = create_valid_image(attachment: fixture_file('story_image.jpg'))
      @image.crops << create_valid_crop(usage: 'gallery:5:3')

      crop_count = @image.crops.count
      expect { @image.destroy }.to change(Crop, :count).by(-crop_count)
    end

  end

  describe "#as_json" do

    before(:each) do
      @image = create_valid_image(author: "Wadus", agency: "reuters", usage_rights: ["canada"], expires_at: @one_week)
    end

    it "exposes a thumb" do
      @image.as_json[:thumb].should == @image.attachment.thumb('100x60#').url
    end

    it "exposes a image" do
      @image.as_json[:image].should == @image.attachment.thumb('200x300#').url
    end

    it "exposes its crops as json" do
      crop = create_valid_crop
      @image.crops << crop

      @image.as_json[:crops].should == [crop.as_json]
    end

    it "exposes its image rights" do
      rights = @image.as_json[:rights]

      rights.should_not be_nil
      rights[:author].should == "Wadus"
      rights[:agency].should == "reuters"
      rights[:expires_at].should == @one_week
      rights[:usage_rights].should == ["canada"]
    end

    it "exposes its gallery crops" do
      image = create_valid_image(attachment: fixture_file('story_image.jpg'))
      image.crops << create_valid_crop(usage: 'gallery:5:3')
      image2 = create_valid_image(attachment: fixture_file('story_image2.jpg'))
      image2.crops << create_valid_crop(usage: 'gallery:3:5')
      story = create_valid_story
      story.images = [image, image2]
      gallery1 = story.crops.gallery[0].as_json
      gallery2 = story.crops.gallery[1].as_json
      gallery1[:usage].should == "gallery:5:3"
      gallery2[:usage].should == "gallery:3:5"
    end

  end

  describe "#rights_as_json" do

    before(:each) do
      @one_week = 1.week.from_now
    end

    context "attachable is nil" do

      it "exposes its own image rights" do
        @image = create_valid_image(author: "Wadus", agency: "reuters", usage_rights: ["canada"], expires_at: @one_week)
        @image.attachable.should be_nil

        rights = @image.rights_as_json
        rights[:author].should == "Wadus"
        rights[:agency].should == "reuters"
        rights[:expires_at].should == @one_week
        rights[:usage_rights].should == ["canada"]
      end

    end

    context "attachable provides image rights" do

      before(:each) do
        @two_weeks = 2.weeks.from_now

        @attachable = mock_model(Story)
        @attachable.stub(:provides_image_rights?).and_return(true)
        @attachable.stub(:requires_full_size_crop?).and_return(false)
        @attachable.stub(:image_rights).and_return(author: "Unknown", agency: "rex", usage_rights: ["worldwide"], expires_at: @two_weeks)

        @image = create_valid_image(author: "Wadus", agency: "reuters", usage_rights: ["canada"], expires_at: @one_week)
        @image.attachable = @attachable
      end

      it "exposes own rights when available" do

        rights = @image.rights_as_json
        rights[:author].should == "Wadus"
        rights[:agency].should == "reuters"
        rights[:expires_at].should == @one_week
        rights[:usage_rights].should == ["canada"]
      end

      it "inherits missing rights from story" do
        @image.update_attributes(author: nil, agency: nil, usage_rights: [], expires_at: nil)

        rights = @image.rights_as_json

        rights[:author].should == "Unknown"
        rights[:agency].should == "rex"
        rights[:expires_at].should == @two_weeks
        rights[:usage_rights].should == ["worldwide"]
      end

    end

    context "attachable does not provide image rights" do

      it "exposes its own image rights" do
        @attachable = mock_model(Story)
        @attachable.stub(:provides_image_rights?).and_return(false)
        @attachable.stub(:requires_full_size_crop?).and_return(false)

        @image = create_valid_image(author: "Wadus", agency: "reuters", usage_rights: ["canada"], expires_at: @one_week)
        @image.attachable = @attachable

        rights = @image.rights_as_json
        rights[:author].should == "Wadus"
        rights[:agency].should == "reuters"
        rights[:expires_at].should == @one_week
        rights[:usage_rights].should == ["canada"]
      end

    end


  end

  describe "#duplicate" do

    before(:each) do
      @image = create_valid_image
    end

    it "number of AR associations is constant" do
      # Please review #duplicate method when adding or removing associations
      # and update this test to match new count
      Image.reflect_on_all_associations.count.should == 2
    end

    it "duplicates image_right" do
      @duplicate = @image.duplicate
      @duplicate.save!

      @duplicate.author.should == @image.author
      @duplicate.agency.should == @image.agency
      @duplicate.usage_rights.should == @image.usage_rights
      @duplicate.expires_at.should == @image.expires_at
    end

    it "duplicates the attachment, correctly" do
      @duplicate = @image.duplicate
      @duplicate.save!

      @duplicate.attachment.should_not == @image.attachment
      @duplicate.attachment.url.should_not == @image.attachment.url
      @duplicate.attachment_uid == @image.attachment_uid
    end

    it "duplicates the caption" do
      @duplicate = @image.duplicate
      @duplicate.save!
      @duplicate.caption.should == @image.caption
    end

    it "duplicates the crops" do
      @image.crops << create_valid_crop(usage: "featured:5:3", top: 1, left: 1, width: 51, height: 31)
      @image.crops << create_valid_crop(usage: "gallery:5:3")
      @image.crops << create_valid_crop(usage: "body:1:1")
      @image.crops << create_valid_crop(usage: "video:16:9")

      @duplicate = @image.duplicate
      @duplicate.save!

      @duplicate.crops.should_not be_empty
      @duplicate.crops.should_not == @image.crops
      @duplicate.crops.featured.size.should == @image.crops.featured.size
      @duplicate.crops.featured.first.top.should == 1
      @duplicate.crops.featured.first.left.should == 1
      @duplicate.crops.featured.first.width.should == 51
      @duplicate.crops.featured.first.height.should == 31
    end

  end

end
