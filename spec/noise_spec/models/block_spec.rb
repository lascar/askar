require 'spec_helper'

describe Block do

  before(:each) do
    @block = create_valid_block
    @block.resume!
    @category = create_valid_category(name: 'Royal')
    @block.categories << @category
  end

  it 'is created as enabled by default' do
    block = Block.create! name: 'Wadus', content_type: 'headline'
    block.should be_enabled
  end

  it 'should require an content_type' do
    @block.content_type = nil
    @block.should_not be_valid
    @block.should have(1).error_on(:content_type)
  end

  it 'suspends itself when html_code changes' do
    block = create_valid_block(content_type: 'html', html_code: '<p>some code</p>')
    block.resume!
    block.html_code = '<p>some other code</p>'
    block.save!
    block.status.should == 'suspended'
  end

  context '(duplicating)' do

    before(:each) do
      @original = @block
      @duplicate = @original.duplicate
    end

    it 'can be duplicated' do
      @original.should_not === @duplicate
    end

    it "maintains the original's sort order" do
      @original.sort_order.should == @duplicate.sort_order
    end

    it "contains duplicates of the original's headline sources" do
      @original.headline_sources.should_not == @duplicate.headline_sources
      @duplicate.headline_sources.collect(&:sourceable_id).should == [@category.id]
    end

  end

  context '(receiving stories)' do
    it 'should not be suspended when receiving a new story' do
      @block.headlines.should be_empty
      story = create_published_story(title: 'Queen Elizabeth is bored')

      @block.receive(story)

      @block.active?.should be_true
    end

    it 'should create a headline when receiving a new story' do
      @block.headlines.should be_empty
      story = create_published_story(title: 'Queen Elizabeth is bored')

      @block.receive(story)

      @block.headlines(true).should_not be_empty
      @block.headlines.count.should == 1
      @block.headlines.first.title.should == 'Queen Elizabeth is bored'
    end

    it 'should not create a headline when receiving a story twice' do
      @block.headlines.should be_empty
      story = create_published_story(title: 'Queen Elizabeth is bored')

      @block.receive(story)
      @block.receive(story)

      @block.headlines(true).should_not be_empty
      @block.headlines.count.should == 1
      @block.headlines.first.title.should == 'Queen Elizabeth is bored'
    end

    it "should update headline's story_published_at when receiving a story" do
      first_publication_date = Time.local(2013, 6, 1)
      Timecop.freeze(first_publication_date)

      story = create_published_story(title: 'Queen Elizabeth is bored')
      @block.receive(story)

      @block.headlines(true).should_not be_empty
      @block.headlines.count.should == 1

      headline = @block.headlines.first
      headline.title.should == 'Queen Elizabeth is bored'
      headline.story_published_at.should == first_publication_date

      second_publication_date = Time.local(2013, 6, 12)
      Timecop.freeze(second_publication_date)

      story.set_published_and_save
      @block.receive(story)
      headline.reload

      story.published_at.should == second_publication_date
      headline.story_published_at.should == story.published_at
      Timecop.return
    end

    it 'should receive all published stories of a newly added category source' do
      category = create_valid_category(name: 'Celebrities')
      story = create_published_story category: category

      @block.categories << category

      @block.headlines.reload.collect(&:story).should == [story]
    end

    it 'should receive all published stories of a newly added tag source' do
      create_valid_tag(name: 'Celebrities')
      story = create_published_story
      tag = ActsAsTaggableOn::Tag.where(name: 'Celebrities').first
      ActsAsTaggableOn::Tagging.create(tag_id: tag.id, taggable_id: story.id, taggable_type: "Story", context: "tags")
      @block.tags << tag

      @block.headlines.reload.collect(&:story).should == [story]
    end

    it 'should exclude all published stories of a newly deleted category source' do
      story = create_published_story category: @category

      @block.headlines.reload.collect(&:story).should  include(story)

      @block.categories = []

      @block.headlines.reload.collect(&:story).should_not  include(story)
    end

    it 'should exclude all published stories of a newly deleted tag source' do
      create_valid_tag(name: 'Celebrities')
      tag = ActsAsTaggableOn::Tag.where(name: 'Celebrities').first
      story = create_published_story
      ActsAsTaggableOn::Tagging.create(tag_id: tag.id, taggable_id: story.id, taggable_type: "Story", context: "tags")
      @block.tags << tag

      @block.headlines.reload.collect(&:story).should  include(story)

      @block.tags = []

      @block.headlines.reload.collect(&:story).should_not  include(story)
    end

    it 'should not receive any unpublished stories of a newly added category source' do
      category = create_valid_category(name: 'Celebrities')
      story = create_valid_story(category: category)

      @block.categories << category

      @block.headlines.reload.collect(&:story).should be_empty
    end

    it 'should receive all published stories of a newly added tag source' do
      tag = create_valid_tag(name: 'Antonio Banderas')

      story = create_published_story(title: 'Prince Harrry lost his clothes, again', creator: 'user', tag_list: ['Antonio Banderas'])

      @block.tags << tag

      @block.headlines.reload.collect(&:story).should == [story]
    end

    it 'should not receive any unpublished stories of a newly added tag source' do
      tag = create_valid_tag(name: 'Antonio Banderas')
      story = create_valid_story tag_list: ['Antonio Banderas']

      @block.tags << tag

      @block.headlines.reload.collect(&:story).should be_empty
    end

    it 'should receive new stories added to an existing category source' do
      category = create_valid_category(name: 'Celebrities')
      @block.categories << category

      story = create_published_story(category: category)

      @block.headlines(true).collect(&:story).should == [story]

      story2 = create_published_story(category: category)

      @block.headlines(true).collect(&:story).should == [story2, story]
    end

    it 'should receive new stories added to an existing tag source' do
      tag = create_valid_tag(name: 'Antonio Banderas')
      @block.tags << tag

      story = create_published_story(creator: 'user', tag_list: ['Antonio Banderas'])

      @block.headlines(true).collect(&:story).should == [story]

      story2 = create_published_story(creator: 'user', tag_list: ['Antonio Banderas'])

      @block.headlines(true).collect(&:story).should == [story2, story ]
    end

  end

  context '(publishing)' do

    before(:each) do
      @block.update_attributes(content_type: 'headlines')
    end

    it 'publishes itself when receiving a new story' do
      story = create_published_story(title: 'Queen Elizabeth is bored')

      @block.should_receive(:publish)

      @block.receive(story)
    end

    it 'does not publish itself when received story is outside the headline limit' do
      @block.update_attributes(headline_limit: 1)

      story1 = create_published_story(title: 'Queen Elizabeth is bored')
      story2 = create_published_story(title: 'King Charles is bored')

      story1.update_attributes(published_at: 1.year.ago)
      story2.update_attributes(published_at: 2.years.ago)

      @block.should_receive(:publish).once

      @block.receive(story1)
      @block.receive(story2)
    end

    it "publishes itself when receiving an updated story and it's not in suspended state" do
      story = create_published_story(title: 'Queen Elizabeth is bored')

      #@block.should_receive(:preview).twice
      @block.should_receive(:publish).twice

      @block.receive(story)
      story.update_attributes(title: 'QE II is bored')

      @block.receive(story)
    end

    it "previews but not publishes itself when receiving an updated story and it's in suspended state" do
      story = create_published_story(title: 'Queen Elizabeth is bored')

      @block.should_receive(:preview).once
      @block.should_receive(:publish).once

      @block.receive(story)
      @block.suspend!
      story.update_attributes(title: 'QE II is bored')

      @block.receive(story)
    end

=begin
    it 'publishes itself if it changes' do
      @block.should_receive(:publish)

      @block.update_attributes(headline_limit: 42)
    end
=end

    it 'suspends itself when a headline notifies it of change' do
      headline = @block.headlines << create_valid_headline(title: 'Title', excerpt: 'Excerpt', url: 'http://hola.com', linked: false)

      @block.should_receive(:suspend!)
      #@block.should_receive(:preview)

      @block.headlines_changed(@block.headlines.last)
    end

    it 'does not preview when it is disabled' do
      story = create_published_story(title: 'Queen Elizabeth is bored')

      @block.disable!
      @block.resume!

      @block.should_not be_enabled
      @block.should be_active

      HeadlineBlockPublisher.should_not_receive(:preview)

      @block.receive(story)
    end

    it 'does not publish when it is disabled but active' do
      story = create_published_story(title: 'Queen Elizabeth is bored')


      @block.disable!
      @block.resume!

      @block.should_not be_enabled
      @block.should be_active

      HeadlineBlockPublisher.should_not_receive(:publish)

      @block.receive(story)
    end
  end

  context '(JSON)' do

    it 'only returns the number of headlines specified by headline_limit' do
      @block.update_attributes headline_limit: 2
      5.times { @block.headlines << create_valid_headline }

      @block.as_json[:headlines].size.should == 2
    end

    it 'returns the html code, if any' do
      @block.update_attributes html_code: '<wadus></wadus>'
      @block.as_json[:html_code].should == '<wadus></wadus>'
    end

    it "exposes the block's name" do
      @block.update_attributes name: 'wadus'
      @block.as_json[:name].should == 'wadus'
    end

    it "exposes the block's content_type" do
      @block.update_attributes content_type: 'wadus'
      @block.as_json[:content_type].should == 'wadus'
    end

    it "exposes the block's style_hint" do
      @block.update_attributes style_hint: 'buttons'
      @block.as_json[:style_hint].should == 'buttons'
    end

  end

  it 'deleting a source, should delete all its headlines, unless they have belong to other sources'

end
