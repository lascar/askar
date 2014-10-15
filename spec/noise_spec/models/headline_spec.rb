require 'spec_helper'

describe Headline do

  context '(linked to a story)' do

    before(:each) do
      @story = create_valid_story(title: "Story title", excerpt: "Story excerpt")
      @story.images << create_valid_image
      @story.images.first.crops << create_valid_crop(usage: "featured:5:3", top: 10, left: 10, width: 100, height: 100)
      @story.set_published_and_save
      @headline = Headline.create(story: @story, linked: true, title: "Headline title", excerpt: "Headline excerpt", url: "/headlines/42")
    end

    it "inherits title from Story#title" do
      @headline.title.should == "Story title"
    end

    it "inherits excerpt from Story#excerpt" do
      @headline.excerpt.should == "Story excerpt"
    end

    it "inherits image from Story#images.featured.first" do
      @headline.image == @story.published_version.images.featured.first
    end

    it "inherits url from Story#slug" do
      @headline.url.should == @story.published_version.slug
    end

    it "doesn't #requires_full_size_crop?" do
      @headline.should_not be_requires_full_size_crop
    end

    it 'sets its :story_published_at to its story published_at' do
      @headline.story_published_at.should == @story.published_at
    end

    describe "#unlink" do

      it "unlinks the story" do
        @headline.should be_linked

        @headline.unlink

        @headline.should_not be_linked
      end

      it "duplicates title from story" do
        @headline.unlink
        @headline.title.should == "Story title"
      end

      it "duplicates excerpt from story" do
        @headline.unlink
        @headline.excerpt.should == "Story excerpt"
      end

      it "duplicates url from Story#slug" do
        @headline.unlink
        @headline.url.should == @story.published_version.slug
      end

      it "duplicates image from story.published_version" do
        @headline.unlink
        @headline.image.should_not == @story.published_version.images.featured.first
        @headline.image.attachment_name.should == @story.images.featured.first.attachment_name
      end

      it "duplicates all featured crops from story.published_version" do
        @headline.unlink

        @headline.crops.featured.size.should be(1)
        @headline.crops.featured.should_not == @story.published_version.crops(true).featured
        @headline.crops.featured.first.top.should be(10)
        @headline.crops.featured.first.left.should be(10)
        @headline.crops.featured.first.width.should be(100)
        @headline.crops.featured.first.height.should be(100)
      end

      it "adds a full size crop" do
        @headline.unlink

        @headline.crops.full_size.size.should == 1
      end
    end

  end

  context '(not linked to a story)' do
    before(:each) do
      @story = create_valid_story(title: "Title", excerpt: "Excerpt", slug: "/stories/42")
      @story.images << create_valid_image
      @story.set_published_and_save
      @headline = Headline.create(story: @story, linked: false, title: "Headline title", excerpt: "Headline excerpt", url: "/headlines/42")
      @image = create_valid_image
      @headline.image = @image
    end

    it "does not inherit title from Story#title" do
      @headline.title.should == "Headline title"
    end

    it "does not inherit excerpt from Story#excerpt" do
      @headline.excerpt.should == "Headline excerpt"
    end

    it "does not inherit images from Story#images" do
      @headline.image.should_not == @story.images.featured.first
      @headline.image.should == @image
    end

    it "does not inherit url from Story#slug" do
      @headline.url.should == "/headlines/42"
    end

    it "#requires_full_size_crop?" do
      @headline.should be_requires_full_size_crop
    end

    it 'sets its :story_published_at to its story published_at' do
      @headline.story_published_at.should == @story.published_at
    end

  end

  context '(pinning)' do

    before(:each) do
      @block = create_valid_block
      @headline = create_valid_headline(title: "Queen Elizabeth II is in you, Dublin!")
      @block.headlines << @headline
    end

    it "sets its position to 1 if no other headlines are pinned" do
      @headline.pin!
      @headline.position.should == 1
    end

    it "sets its position to the next available one" do
      @block.headlines << create_valid_headline(position: 5)
      @headline.pin!
      @headline.position.should == 6
    end

    it "sets its position to nil when unpinned" do
      @headline.unpin!
      @headline.position.should be_nil
    end

    it "is pinned when it has a position" do
      @headline.should_not be_pinned
      @headline.pin!
      @headline.should be_pinned
    end

  end

  context '(ordering inside headline block)' do

    before(:each) do
      @story1 = create_valid_story(published_at: 1.day.ago)
      @story2 = create_valid_story(published_at: 1.day.from_now)
      @headline1 = create_valid_headline(title: "From story 1", story: @story1)
      @headline2 = create_valid_headline(title: "From story 2", story: @story2)
      @block = create_valid_block
      @headline = create_valid_headline(title: "Queen Elizabeth II is in you, Dublin!")
      @block.headlines << create_valid_headline(title: "Second pinned", position: 2)
      @block.headlines << create_valid_headline(title: "Top pinned", position: 1)
      @block.headlines << create_valid_headline(title: "Oldest standalone unpinned")
      @block.headlines << @headline1
      @block.headlines << create_valid_headline(title: "Newest standalone unpinned")
      @block.headlines << @headline2
      @block.headlines.reload
    end

    it "sorts by ascending position first" do
      @block.headlines[0].title.should == "Top pinned"
      @block.headlines[1].title.should == "Second pinned"
    end

    it "sorts by story publication date secondly" do
      @block.headlines[2].title.should == "From story 2"
      @block.headlines[3].title.should == "Newest standalone unpinned"
      @block.headlines[4].title.should == "Oldest standalone unpinned"
      @block.headlines[5].title.should == "From story 1"
    end

  end

  context '(for a story)' do

    before(:each) do

      @block = create_valid_block
      @headline = Headline.new(title: "The Queen Mother rises from the grave", url: "http://example.com", excerpt: "Wadus")
      @headline.container = @block
      @headline.image = create_valid_image
      @headline.save!

    end

    it "notifies its block when title, url or excerpt are changed" do
      @block.should_receive(:headlines_changed).with(@headline).exactly(3).times

      @headline.update_attributes(title: "Overriden title")
      @headline.update_attributes(url: "http://apple.com")
      @headline.update_attributes(excerpt: "Overriden excerpt")
    end

    it "notifies its block when pinned" do
      @block.should_receive(:headlines_changed).with(@headline).once

      @headline.pin!
    end

    it "notifies its block when image is changed" do
      # Work around `any_instance` requiring the same instance for all expectations
      # Setting an image directly would have cause two calls, one when destroying the
      # old headline image (dependent destroy), and one when setting the new headline image
      @headline.image = nil

      Block.any_instance.should_receive(:headlines_changed).with(@headline).once
      @headline.image = create_valid_image
    end

    it "notifies its block when image is removed" do
      Block.any_instance.should_receive(:headlines_changed).with(@headline).once

      @headline.image.destroy
    end

  end

  context '(for an external link)' do

    before(:each) do
      @headline = Headline.new title: 'The Queen Mother rises from the grave',
                               excerpt: 'Just your run of the mill royal zombie resurection incident',
                               url: 'http://example.com',
                               image: create_valid_image

      @headline.story = nil

      @headline.should be_valid
    end

    it 'should require a title' do
      @headline.title = nil
      @headline.should_not be_valid
      @headline.should have(1).error_on(:title)
    end

    it 'should require a url' do
      @headline.url = nil
      @headline.should_not be_valid
      @headline.should have(1).error_on(:url)
    end

    it 'should not require an image' do
      @headline.image = nil
      @headline.should be_valid
    end

    it 'sets its :story_published_at to :created_at' do
      @headline.save
      @headline.story_published_at.should == @headline.created_at
    end

    it "notifies its block when title or excerpt are changed" do

      block = create_valid_block
      @headline.container = block

      @headline.save!

      block.should_receive(:headlines_changed).with(@headline).exactly(2).times

      @headline.update_attributes(title: "New title")
      @headline.update_attributes(excerpt: "New excerpt")

    end

    it "notifies its block when pinned" do

      block = create_valid_block
      @headline.container = block

      @headline.save!

      block.should_receive(:headlines_changed).with(@headline).once

      @headline.pin!
    end


    it "notifies its block when images" do

      block = create_valid_block
      @headline.container = block

      @headline.save!

      @headline.should_receive(:notify_block).once

      @headline.images_changed(nil)
    end

  end

  context "images' publication" do
    before(:each) do
      @image1 = create_valid_image

      @image1.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)

      @headline = Headline.new(title: "Headline title", url: "http://www.example.com")
      @headline.image = @image1
      @headline.save!
    end

    it "returns the crop for front page" do
      @headline.crops.featured.to_a.should == @image1.crops.featured.to_a
    end

  end

  describe "#as_json" do

    before(:each) do
      @headline = create_valid_headline(linked:false, title: "Title", url: "/headlines/42", excerpt: "Excerpt", secondary_url: "/secondary/42", open_in_new_window: true)
    end

    it "exposes its title" do
      @headline.as_json[:title].should == "Title"
    end

    it "exposes its url" do
      @headline.as_json[:url].should == "/headlines/42"
    end

    it "exposes its excrept" do
      @headline.as_json[:excerpt].should == "Excerpt"
    end

    it "exposes its secondary_url" do
      @headline.as_json[:secondary_url].should == "/secondary/42"
    end

    it "exposes its date" do
      @headline.as_json[:date].should == @headline.created_at
    end

    context "for a story" do

      before(:each) do
        @category = create_valid_category(name: "Category")
        @story = create_published_story(category: @category)
        @headline.story = @story
        @headline.update_attribute(:linked, true)
      end

      it "exposes its story_id" do
        @headline.as_json[:story_id].should == @story.id
      end

      it "exposes its category_name" do
        @headline.as_json[:category_name].should == "Category"
      end

      it "exposes its category_path_slug" do
        @headline.as_json[:category_path_slug].should == @category.path_slug
      end

      it "exposes its story url" do
        @headline.as_json[:url].should == @story.publish_url
      end

    end

    it "exposes its open_in_new_window" do
      @headline.as_json[:open_in_new_window].should == true
    end

    it "exposes its featured_crop" do
      @headline.image = create_valid_image
      @headline.image.crops << create_valid_crop(usage: "featured:5:3")

      @headline.as_json[:featured_crop].should be_present
      @headline.as_json[:featured_crop].should == @headline.crops.featured.first.as_json
    end

    it "exposes its full_size_crop" do
      @headline.image = create_valid_image

      @headline.as_json[:full_size_crop].should be_present
      @headline.as_json[:full_size_crop].should == @headline.crops.full_size.first.as_json
    end

  end

  context 'orphans' do
    before do
      story1 = create_published_story
      story2 = create_published_story
      @headline1 = create_valid_headline(story: story1, linked: true)
      @headline2 = create_valid_headline(story: story2, linked: true)
      @headline3 = create_valid_headline(title: "Standalone", linked: false)

      story1.delete
      @headline1.reload
    end

    describe ".not_orphans" do
      it 'returns not linked headlines or linked ones with related stories' do
        Headline.not_orphans.should == [@headline2, @headline3]
      end
    end

    describe ".linked_not_orphans" do
      it 'returns linked headlines with related stories' do
        Headline.linked_not_orphans.should == [@headline2]
      end
    end

    describe 'parent methods on orphans' do
      %w(title title_before_type_cast excerpt excerpt_before_type_cast url
         url_before_type_cast thumb_url).each do |method|
        it "does not throw error on calling orphan #{method} method" do
          @headline1.send(method.to_sym).should be_nil
        end
      end
    end
  end
end
