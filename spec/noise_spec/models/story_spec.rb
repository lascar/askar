require 'spec_helper'

describe Story do

  it 'should be valid' do
    story = new_valid_story
    story.should be_valid
  end

  it 'is invalid without a title' do
    story = create_valid_story
    story.title = nil
    story.should_not be_valid
    story.should have(1).error_on(:title)
  end

  it 'is invalid with an empty title' do
    story = create_valid_story
    story.title = ' '
    story.should_not be_valid
    story.should have(1).error_on(:title)
  end

  it 'has one primary category' do
    story = create_valid_story

    story.secondary_categories.should be_empty

    story.category = create_valid_category(name: 'Royalty')
    story.reload.category.name.should == 'Royalty'
  end

  describe 'default categories for document types' do
    before(:each) do
      @magazine_category = create_valid_category(name: 'Magazine category', document_type: 'magazine')
    end

    it 'sets the default category for the document type if one exists' do
      story = create_valid_story(story_type: 'Magazine')
      story.category.name.should == 'Magazine category'
    end

    it 'does not permit changing the default category' do
      story = create_valid_story(story_type: 'Magazine')
      story.category = create_valid_category(name: 'Other category')
      story.save!

      story.reload.category.name.should == 'Magazine category'
    end

    describe '#has_default_category?' do

      it 'is true for document types with a default category' do
        story = create_valid_story(story_type: 'Magazine')
        story.should have_default_category
      end

      it 'is false for document types without a default category' do
        story = create_valid_story(story_type: 'NewsStory')
        story.should_not have_default_category
      end
    end

  end

  it 'has zero ore more secondary categories' do
    story = create_valid_story
    story.secondary_categories.should be_empty

    story.secondary_categories << create_valid_category(name: 'Sport')
    story.secondary_categories.length.should == 1
    story.secondary_categories.first.name.should == 'Sport'
  end

  it "secondary categories don't include the primary category" do
    story = create_valid_story
    story.secondary_categories = [create_valid_category, create_valid_category]
    story.secondary_categories.should_not include(story.category)
  end

  it "it's invalid if primary category is included in secondary categories" do
    story = create_valid_story
    story.secondary_categories = [create_valid_category, create_valid_category, story.category]
    story.should_not be_valid
    story.should have(1).error_on(:secondary_categories)
  end

  describe 'inherited attributes' do
    before(:each) do
      @area_one = create_valid_area
      @category = create_valid_category(name: 'Some category', area_id: @area_one.id, comments_status: 'enabled')
      @story = create_valid_story(category: @category)
    end

    it "inherits area_id from the primary category's page" do
      @story.area_id.should == @area_one.id
    end

    it "can override the area_id it inherits" do
      @area_two = create_valid_area
      @story.area = @area_two
      @story.save!
      @story.reload
      @story.area_id.should == @area_two.id
    end

    it "inherits comments_status from the primary category's page" do
      @story.comments_status.should == @category.comments_status
    end

    it "inherits comments_status from the primary category's page when blank" do
      @story.comments_status = ""
      @story.save!
      @story.reload
      @story.comments_status.should == @category.comments_status
    end

    it "can override the comments_status it inherits" do
      @story.comments_status = "disabled"
      @story.save!
      @story.reload
      @story.comments_status.should == "disabled"
    end

  end

  describe "#as_json" do
    before(:each) do
      @category = create_valid_category

      create_valid_property_type(name: "news_story_property", story_type: "NewsStory")
      @story =  create_valid_story(category: @category, title:'The Queen Mother rises from the grave', pageid: 'XYZ', pageid_name: 'ZXY', comments_status: 'enabled', gallery_pageid: "QWERTY", gallery_pageid_name: "DVORAK")

      @story.set_published_and_save
    end

    it "exposes its title" do
      @story.as_json[:title].should == @story.title
    end

    it "exposes its subtitle" do
      @story.as_json[:subtitle].should == @story.subtitle
    end

    it "exposes its inner related story" do
      inner_related = create_published_story(category: @category, title:'Related Story', excerpt: 'Related excerpt')
      @story.headlines.create(linked: true, story: inner_related)

      @story.reload

      json = @story.as_json[:inner_related_stories].first
      json[:title].should == inner_related.title
      json[:excerpt].should == inner_related.excerpt
      json[:url].should == inner_related.preview_slug
    end

    it "does not expose missing inner related stories with orphan headlines" do
      inner_related = create_published_story(category: @category, title:'Related Story', excerpt: 'Related excerpt')
      @story.headlines.create(linked: true, story: inner_related)
      inner_related.delete

      @story.reload

      @story.as_json[:inner_related_stories].first.should be_nil
    end

    it "exposes its external related story" do
      @story.headlines.create!(title: "External headline", linked: false, excerpt: "External excerpt", url: "http://apple.com")

      @story.reload

      json = @story.as_json[:external_related_stories].first

      json[:title].should == 'External headline'
      json[:excerpt].should == 'External excerpt'
      json[:url].should == 'http://apple.com'
    end

    it "exposes its crops" do
      image1 = create_valid_image(caption: "Caption 1")
      image2 = create_valid_image(caption: "Caption 2")

      image1.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)
      @story.images = [image1, image2]

      @story.as_json[:crops].should == @story.crops.as_json
    end

    it "exposes its properties" do
      @story.as_json[:properties].first[:value].should == @story.properties.first.value
    end

    it "exposes its area" do
      area = create_valid_area name: "Area 1"
      block = create_valid_block
      @story.area = area
      @story.area.blocks << block

      @story.as_json[:area][:name].should == "Area 1"
      @story.as_json[:area][:blocks].should == [block.id]
    end

    it "exposes its main category" do
      @story.as_json[:category].should == @story.category.as_json
    end

    it "exposes its tags" do
      @persons = ['Person 1', 'Person 2']
      @story.person_list = @persons
      @story.save!

      @story.reload.as_json[:tags][:people].should == [{label: 'Person 1', slug: 'person-1'}, {label: 'Person 2', slug: 'person-2'}]
    end

    it "exposes its url_path" do
      @story.as_json[:url_path].should == @story.slug
    end

    it "exposes its formatted publication date" do
      @story.as_json[:published_at].should == @story.published_at.strftime("%Y-%m-%d")
    end

    it "exposes its formatted creation date" do
      @story.as_json[:created_at].should == @story.created_at.strftime("%Y-%m-%d")
    end

    it "exposes its secondary categories" do
      cat1 = create_valid_category(name: "Sport")
      cat2 =  create_valid_category(name: "Fashion Brides")
      @secondary_categories = [cat1, cat2]
      @story.secondary_categories = @secondary_categories

      @story.as_json[:secondary_categories].count.should be(2)
      @story.as_json[:secondary_categories].should include({ id: cat1.id, name: "Sport", path_slug: "sport", name_slug: "sport"})
      @story.as_json[:secondary_categories].should include({ id: cat2.id, name: "Fashion Brides", path_slug: "fashion-brides", name_slug: "fashion-brides"})

    end

    it "exposes its editorial versions" do
      @story.as_json[:editorial_versions].should == @story.editorial_versions.as_json
    end

    it "exposes its template" do
      story_template = create_valid_story_template
      @story.story_template = story_template
      @story.save!

      @story.reload.as_json[:template].should == story_template.as_json
    end

    it "exposes its comments' behaviour" do
      @story.comments_status = true

      @story.as_json[:comments].should be_true
    end

    it "exposes its publicity_formats" do
      @story.update_attributes(publicity_formats: ["dhtml:5347"])
      @story.as_json[:publicity_formats].should == [{name: "dhtml", id: "5347"}]
    end

    it "exposes its pageid" do
      @story.as_json[:pageid].should == @story.pageid
    end

    it "exposes its pageid_name" do
      @story.as_json[:pageid_name].should == @story.pageid_name
    end

    it "exposes its gallery_pageid" do
      @story.as_json[:gallery_pageid].should == @story.gallery_pageid
    end

    it "exposes its gallery_pageid_name" do
      @story.as_json[:gallery_pageid_name].should == @story.gallery_pageid_name
    end

    it "exposes its seo element" do
      @story.as_json[:seo_element].should == @story.seo_element.as_json
    end

    it "exposes its preview_slug as its url_path  (for a draft story)" do

      create_valid_property_type(name: "news_story_property", story_type: "NewsStory")
      draft_story =  create_valid_story(category: @category, title:'The Queen Mother rises from the grave', pageid: 'XYZ', pageid_name: 'ZXY', comments_status: 'enabled', gallery_pageid: "QWERTY", gallery_pageid_name: "DVORAK")

      draft_story.as_json[:url_path].should == draft_story.preview_slug
    end

    it 'exposes its datalayer' do
      serialized = {key: 'value'}
      StoryDatalayerSerializer.stub_chain(:new, :as_json).and_return(serialized)
      @story.as_json[:data_layer].should == serialized
    end
  end

  describe "#duplicate" do

    before(:each) do
      create_valid_property_type(name: "Author")

      @story = create_published_story
      @story.update_attributes image_author: "Christos", image_agency: "hola", image_usage_rights: ["worldwide"], image_expires_at: 1.week.from_now

      @story.save!

      @story.properties.first.update_attributes(value: "Our Author")

      @story.images = [create_valid_image(caption: "Lorem caption")]
      @story.images.first.crops << create_valid_crop(usage: "video:16:9")

      @story.headlines.create!(title: "Headline title", url: "headline/url", linked: false)
      @story.headlines.create!(linked: true, story: create_published_story)

      @duplicate = @story.duplicate
      @duplicate.save!
    end

    it "number of AR associations is constant" do
      # Please review #duplicate method when adding or removing associations
      # to Story, and update this test to match new count
      Story.reflect_on_all_associations.count.should == 34
    end

    it "duplicates all attributes" do
      [:title, :excerpt, :subtitle, :body, :published_at, :first_published_at,
       :area_id, :slug, :title_slug, :creator, :story_template_id,
       :comments_status, :publicity_formats, :pageid, :pageid_name,
       :gallery_pageid, :gallery_pageid_name].each do |attribute|
         @duplicate.send(attribute).should == @story.send(attribute)
      end
    end

    it "duplicates seo_element" do
      @duplicate.seo_element.tap do |dup|
        dup.should_not == @story.seo_element
        [:meta_title, :meta_description, :meta_keywords, :url_base, :canonical,
         :redirection].each do |attribute|
          dup.send(attribute).should == @story.seo_element.send(attribute)
        end
      end
    end

    it "duplicates default image rights" do
      @duplicate.image_agency.should == @story.image_agency
      @duplicate.image_author.should == @story.image_author
      @duplicate.image_usage_rights.should == @story.image_usage_rights
      @duplicate.image_expires_at.should == @story.image_expires_at
    end

    it "duplicates all tag lists" do
      [:tag_list, :person_list, :brand_list, :place_list, :institution_list,
       :company_list].each do |attribute|
         @duplicate.send(attribute).should == @story.send(attribute)
      end
    end

    it "duplicates all properties" do
      @duplicate.properties.should_not == @story.properties
      @duplicate.properties.collect(&:value).should == ["Our Author"]
    end

    it "duplicate primary and secondary categories" do
      @duplicate.category.should == @story.category
      @duplicate.secondary_categories.should == @story.secondary_categories
    end

    it "duplicates editorial versions" do
      @duplicate.editorial_versions.should_not == @story.editorial_versions
      @duplicate.editorial_versions.collect(&:title).should == @story.editorial_versions.collect(&:title)
    end

    it "duplicates headlines" do
      @duplicate.headlines(true).should_not == @story.headlines(true)
      @duplicate.headlines(true).collect(&:title).sort.should == @story.headlines(true).collect(&:title).sort
    end

    it "does not duplicate orphan headlines" do
      linked_story = create_published_story
      @story.headlines.create!(linked: true, story: linked_story)
      linked_story.delete

      @duplicate = @story.duplicate

      @duplicate.headlines.size.should == @story.headlines.size - 1
    end

    it "duplicates images and crops" do
      @duplicate.images.should_not == @story.images
      @duplicate.images.collect(&:caption).should == ["Lorem caption"]

      @duplicate.crops.should_not == @story.crops
      @duplicate.crops.collect(&:usage).sort.should == ["video:16:9"]
    end

  end

  describe "#headline_limit" do
    it "should always be 0" do
      @story = create_valid_story
      @story.headline_limit.should be(0)

      @story = Story.new
      @story.headline_limit.should be(0)

    end
  end

  it "destroys any image, when destroyed" do
    story = create_valid_story
    story.images.create!(attachment: fixture_file('story_image.jpg'))

    expect { story.destroy }.to change(Image, :count).by(-1)

  end

  describe "#all_tags" do
    it "returns all the story tags grouped by context" do
      story = create_valid_story

      story.tagging_contexts.each do |context|
        tags = ["#{context} 1", "#{context} 2"]

        story.send("#{context.singularize}_list=", tags)

        story.all_tags[context.to_sym].should == tags.map{ |tag| {label: tag, slug: tag.parameterize} }
      end

    end
  end

  describe "#all_tag_values" do
    it "returns all the story tags values" do
      story = create_valid_story

      tags = []
      story.tagging_contexts.each do |context|
        context_tags = ["#{context} 1", "#{context} 2"]

        story.send("#{context.singularize}_list=", context_tags)
        tags.concat(context_tags)
      end
      story.all_tag_values.should == tags
    end
  end


  describe "#set_published_and_save" do
    let(:story) { create_valid_story }

    before(:each) do
      # Story.any_instance.stub(:set_slug)
      # Story.any_instance.stub(:send_to_headlines)
      # Story.any_instance.stub(:send_to_taggings)
    end

    it "updates the published_at and first_published_at fields the first time it is published" do
      story.should_receive(:touch).with(:published_at)
      story.should_receive(:touch).with(:first_published_at)

      story.set_published_and_save
    end

    it "updates only the published_at field on subsequent calls" do
      story.set_published_and_save

      story.should_receive(:touch).with(:published_at)
      story.should_not_receive(:touch).with(:first_published_at)

      story.set_published_and_save
    end

    it "sets the title_slug" do
      story.title_slug = nil

      story.should_receive(:title_slug=).with(story.title.parameterize)

      story.set_published_and_save
    end

    it "does not set the title_slug if it is already set" do
      story.title_slug = 'title_slug'

      story.should_not_receive(:title_slug=)

      story.set_published_and_save
    end

    it "calls send_to_blocks" do
      story.should_receive(:send_to_blocks)

      story.set_published_and_save
    end

    it "calls send_to_taggings" do
      story.should_receive(:send_to_blocks)

      story.set_published_and_save
    end
  end

  describe "#set_slug" do
    before(:each) do
      PUBLISH_CONFIG[:publication_url_prefix_id] = "007"
    end

    def set_story_published(story)
      story.touch(:published_at)
      story.touch(:first_published_at)
      story.title_slug = story.title.parameterize
      story
    end

    it "only sets the slug when published" do
      story = create_valid_story
      story.set_slug
      story.slug.should be_nil
    end
    it "sets the slug for news stories" do
      category = create_valid_category
      story = create_valid_story(category: category, story_type: "NewsStory")
      story = set_story_published(story)

      story.set_slug

      story.slug.should == "/#{category.path_slug}/007#{story.first_published_at.strftime('%Y%m%d')}#{story.id.to_s}/#{story.title_slug}"
    end
    it "sets the slug for biographies" do
      story = create_valid_story(story_type: "Biography")
      story = set_story_published(story)

      story.set_slug

      story.slug.should == "/profiles/#{story.title_slug}"
    end
    it "sets the slug for recipes" do
      category = create_valid_category(name: "Cuisine")

      story = create_valid_story(category: category, story_type: "Recipe")
      story = set_story_published(story)

      story.set_slug

      story.slug.should == "/#{category.path_slug}/007#{story.first_published_at.strftime('%Y%m%d')}#{story.id.to_s}/#{story.title_slug}"
    end

    it "sets the slug for magazines" do
      story = create_valid_story(story_type: "Magazine")
      story = set_story_published(story)

      story.should_receive(:get_property_value_by_type).with('Issue').and_return(100)

      story.set_slug
      story.slug.should == "/magazine/100"
    end

    it "sets the slug for albums" do
      category = create_valid_category(name: "Toronto Special")

      story = create_valid_story(category: category, story_type: "Album")
      story = set_story_published(story)

      story.set_slug

      story.slug.should == "/#{category.path_slug}/photo-galleries/007#{story.first_published_at.strftime('%Y%m%d')}#{story.id.to_s}/#{story.title_slug}"
    end

  end

  describe "categorisation" do

    before(:each) do
      @story = Story.new do |s|
        s.title = "Queen Elizabeth II will be visiting Belfast"
        s.body = "wadus"
        s.excerpt = "wadus"
        s.category = create_valid_category(name: 'General')
      end

      @results = {}
      @results[:categories] = [['Royalty', []], ['UK', []]]
      @results[:tags]  = ['Monarchy']
      @results[:places] = ['Belfast']
      @results[:people] = ['Queen Elizabeth II']
      @results[:institutions] = ['British Monarchy']
      @results[:brands] = ['Queen']
      @results[:companies] = ['Royal Theater Company']

      TaggingService.stub!(:classify).with(title: @story.title, body: @story.body).and_return(@results)
    end

    it "is categorised" do
      @story.categorize!
      @story.categorized?.should == true
      # Until we have the new tagging service working the automatic secondary categories will be disabled
      # @story.secondary_categories.collect(&:name).should == ['Royalty', 'UK']
    end

    it "is tagged" do
      @story.categorize!
      @story.categorized?.should == true
      @story.tag_list.should == ['Monarchy']
      @story.place_list.should == ['Belfast']
      @story.person_list.should == ['Queen Elizabeth II']
      @story.institution_list.should == ['British Monarchy']
      @story.brand_list.should == ['Queen']
      @story.company_list.should == ['Royal Theater Company']
    end

    it "it merges new tags with existing tags" do
      @story.tag_list = ['wadus']
      @story.place_list = ['wadus']
      @story.person_list = ['wadus']
      @story.institution_list = ['wadus']
      @story.brand_list = ['wadus']
      @story.company_list = ['wadus']

      @story.categorize!

      @story.tag_list.should == ['wadus', 'Monarchy']
      @story.place_list.should == ['wadus', 'Belfast']
      @story.person_list.should == ['wadus', 'Queen Elizabeth II']
      @story.institution_list.should == ['wadus', 'British Monarchy']
      @story.brand_list.should == ['wadus', 'Queen']
      @story.company_list.should == ['wadus', 'Royal Theater Company']
    end

    it "is not automatically tagged when created" do
      @story.save!

      @story.tag_list.should_not include('Monarchy')
      @story.place_list.should_not include('Belfast')
      @story.person_list.should_not include('Queen Elizabeth II')
      @story.institution_list.should_not include('British Monarchy')
      @story.brand_list.should_not include('Queen')
      @story.company_list.should_not include('Royal Theater Company')
    end

    it "is not automatically tagged when updated" do
      @story.categorize!

      @results[:categories] = []
      @results[:tags]  = ['wadus']
      @results[:places] = ['wadus']
      @results[:people] = ['wadus']
      @results[:institutions] = ['wadus']
      @results[:brands] = ['wadus']
      @results[:companies] = ['wadus']

      @story.title = "Queen Elizabeth II will be visiting Northern Ireland"
      TaggingService.stub!(:classify).with(title: @story.title, body: @story.body).and_return(@results)
      @story.save!

      @story.tag_list.should_not include('wadus')
      @story.place_list.should_not include('wadus')
      @story.person_list.should_not include('wadus')
      @story.institution_list.should_not include('wadus')
      @story.brand_list.should_not include('wadus')
      @story.company_list.should_not include('wadus')
    end

  end

  describe "#publishable?" do
    before(:each) do
      @story = create_published_story
      @story.should be_publishable
    end

    it "is not publishable without a title" do
      @story.title = ""

      @story.should_not be_publishable
    end

    it "is not publishable without an excerpt" do
      @story.excerpt = ""

      @story.should_not be_publishable
    end

    it "is not publishable without a body" do
      @story.body = ""

      @story.should_not be_publishable
    end

    it "is not publishable without categorization" do
      @story.tag_list = []
      @story.person_list = []
      @story.brand_list == []
      @story.place_list = []
      @story.institution_list = []
      @story.company_list = []
      @story.save!
      @story.reload

      @story.should_not be_categorized
      @story.should_not be_publishable
    end

    it "is not publishable without default image agency" do
      @story.image_agency = ""

      @story.should_not be_publishable
    end

    it "is not publishable without a featured crop" do
      @story.crops.featured.destroy_all
      @story.should_not be_publishable
    end

  end

  describe "TagHeadlines" do

    describe "Tagging an unpublished story" do
      it "doesn't create any TagHeadlines" do
        story = create_valid_story
        story.should_not be_published
        expect {
          story.tag_list = ['Tag1']
          story.place_list = ['Tag2']
          story.person_list = ['Tag3']
          story.institution_list = ['Tag4']
          story.brand_list = ['Tag5']
          story.company_list = ['Tag6']
          story.save!
        }.to_not change(TagHeadline, :count)
      end
    end

    describe "Tagging and publishing a story" do
      it "creates TagHeadlines for the new Tags" do
        story = create_valid_story(image_agency: "gettyimages", image_author: "Helmut Newton")
        story.images.create!(attachment: fixture_file('story_image.jpg'), caption: 'Story image caption')
        story.images.last.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)
        story.reload.set_published_and_save

        expect {
          story.tag_list = ['Tag1']
          story.place_list = ['Tag2']
          story.person_list = ['Tag3']
          story.institution_list = ['Tag4']
          story.brand_list = ['Tag5']
          story.company_list = ['Tag6']
          story.save!
          story.set_published_and_save
        }.to change(TagHeadline, :count).by(6)

      end
    end

    describe "Removing a tag from a published story" do
      it "Deletes the TagHeadline for the removed tag" do
        story = create_valid_story(tag_list: ['Tag1'], place_list: ['Tag2'])
        story.images.create!(attachment: fixture_file('story_image.jpg'), caption: 'Story image caption')
        story.images.last.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)

        story.set_published_and_save

        expect {
          story.tag_list = ['']
          story.place_list = ['']
          story.save!
          story.set_published_and_save
        }.to change(TagHeadline, :count).by(-2)

      end
    end

    describe "Publishing a tagged story" do
      it "creates TagHeadlines for each tag" do
        story = create_valid_story
        story.images.create!(attachment: fixture_file('story_image.jpg'), caption: 'Story image caption')
        story.images.last.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)
        story.should_not be_published

        story.tag_list = ['Tag1']
        story.place_list = ['Tag2']
        story.person_list = ['Tag3']
        story.institution_list = ['Tag4']
        story.brand_list = ['Tag5']
        story.company_list = ['Tag6']
        story.save!

        expect {
          story.set_published_and_save
        }.to change(TagHeadline, :count).by(6)

      end
    end
  end

  describe "seo element" do
    it "is not empty after story creation" do
      story = Story.new

      seo_element = story.seo_element

      seo_element.should_not be_nil
    end
  end

  context "Property accessors" do
    before(:each) do
      @story = create_valid_story(story_type: "Magazine")
      @property_type_name = "magazine_property"
      @property_type = create_valid_property_type(name: @property_type_name, story_type: "Magazine")
      @value = 'value'
      @story.properties.clear
      @story.properties.build(property_type_id: @property_type.id, value: @value)
    end

    describe ".get_property_value_by_type" do
      it "returns the value of one property by the name of its property_type" do
        @story.get_property_value_by_type(@property_type_name).should == @value
      end

      it "is case insensitive" do
        @story.get_property_value_by_type(@property_type_name.upcase).should == @value
      end
    end

    describe ".set_property_value_by_type" do
      it "sets the value of one property using the name of the property_type" do
        @story.set_property_value_by_type(@property_type_name, 'value2')
        @story.properties[0].value.should == 'value2'
      end
    end
  end

  describe "#requires_full_size_crop?" do

    it "should be true for 'Magazine' story type" do
      story = create_valid_story(story_type: "Magazine")
      story.should be_requires_full_size_crop
    end

    it "should be false for all other story types apart from 'Magazine'" do
      (Story.story_type_choices - [Story.story_type_choices.rassoc('Magazine')]).each do |type|
        story = create_valid_story(story_type: type.first)
        story.should_not be_requires_full_size_crop
      end
    end

  end

  describe "#provides_image_rights?" do
    it "should be true" do
      story = create_valid_story
      story.should be_provides_image_rights
    end
  end

  it "exposes image rights as a hash" do
    expires_at = 1.week.from_now
    default_image_rights = {
      image_author: "Wadus",
      image_agency: "rex",
      image_usage_rights: ["usa"],
      image_expires_at: expires_at
    }
    story = create_valid_story(default_image_rights)

    image_rights = story.image_rights
    image_rights[:author].should == "Wadus"
    image_rights[:agency].should == "rex"
    image_rights[:usage_rights].should == ["usa"]
    image_rights[:expires_at].should == expires_at
  end

  describe "unsecures video links" do
    it "replaces brightcove secure links in body upon save" do
      story = create_valid_story
      story.update_attributes(body: Story::SECURE_VIDEO_LINK_PREFIX)
      story.body.should == Story::UNSECURE_VIDEO_LINK_PREFIX
    end
  end

  describe "#secure_video_links" do
    it "replaces brightcove insecure links in body by the secure ones" do
      story = create_valid_story
      story.update_attributes(body: Story::UNSECURE_VIDEO_LINK_PREFIX)
      story.secure_video_links

      story.body.should == Story::SECURE_VIDEO_LINK_PREFIX
    end
  end

  shared_examples 'a url generator method' do |input_url, method|
    it "returns the preview url for regular stories" do
      story = create_valid_story

      expect(story.send(method)).to eql "#{input_url}#{story.preview_slug}"
    end

    it 'returns the preview url with related subdomain for specials stories' do
      category = create(:category, :with_subdomain)

      StringUtils.any_instance
        .should_receive(:insert_subdomain)
        .with(input_url, category.related_subdomain)
        .and_return('url_with_subdomain')

      story = create_valid_story(category: category)

      expect(story.send(method)).to eql "url_with_subdomain#{story.preview_slug}"
    end
  end

  describe '#preview_url' do
    it_behaves_like 'a url generator method', PUBLISH_CONFIG[:preview_host], :preview_url
  end

  describe '#publish_url' do
    it_behaves_like 'a url generator method', PUBLISH_CONFIG[:publication_host], :publish_url
  end

  describe '#all_published' do
    include_context 'all kinds of stories'
    before(:each) { @result = Story.all_published }
    it 'returns published stories owned by all users' do
      expect(@result.size).to be (@size * 2)
      expect(@result).to match_array(all_published)
    end
    it_behaves_like "sorted list by published_at in descending order"
  end

  describe '#published_owned_by' do
    include_context 'all kinds of stories'
    before(:each) { @result = Story.published_owned_by(user) }
    it 'returns published stories owned by user' do
      expect(@result.size).to be @size
      expect(@result).to match_array(@published_by_user)
    end
    it_behaves_like "sorted list by published_at in descending order"
  end

  describe '#all_drafts' do
    include_context 'all kinds of stories'
    before(:each) { @result = Story.all_drafts }
    it 'returns drafts stories owned by all users' do
      expect(@result.size).to be (@size * 2)
      expect(@result).to match_array(all_drafts)
    end
    it_behaves_like "sorted list by updated_at in descending order"
  end

  describe '#drafts_owned_by' do
    include_context 'all kinds of stories'
    before(:each) { @result = Story.drafts_owned_by(user) }
    it 'returns drafts stories owned by user' do
      expect(@result.size).to be @size
      expect(@result).to match_array(@drafts_by_user)
    end
    it_behaves_like "sorted list by updated_at in descending order"
  end
end
