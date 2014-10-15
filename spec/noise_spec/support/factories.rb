module FactoryHelpers

  def create_missing_content(campos)
    campos.each do |campo|
      if campo === "Section"
       select  "Royalty", from: "Section"
      else
       fill_in campo,   with: Faker::Name.name
      end
    end
  end

  def new_valid_story(attrs = {})
    creator = attrs.delete(:creator)
    attrs.reverse_merge!(
      title: Faker::Name.name,
      subtitle: Faker::Name.name,
      excerpt: Faker::Name.name,
      body: Faker::Name.name,
      category: create_valid_category,
      pageid: "page id",
      pageid_name: "page id name",
      gallery_pageid: "gallery pageid",
      gallery_pageid_name: "gallery pageid name",
      publicity_formats: ["dhtml:5347"]
    )
    story = Story.new(attrs)
    story.creator = creator || 'creator'
    story
  end

  def create_valid_story(attrs = {})
    story = new_valid_story(attrs)
    story.save!
    story
  end

  def new_valid_related_story(attrs = {})
    attrs.reverse_merge!(
      story_id: create_valid_story.id,
      relatable: create_valid_story
    )
    RelatedStory.new(attrs)
  end

  def create_valid_related_headline(attrs = {})
    related = new_valid_related_story(attrs)
    related.save!
    related
  end

  def create_published_story(attrs = {})
    attrs.reverse_merge!(slug: "/slug", image_agency: "gettyimages")
    story = create_valid_story(attrs)
    story.tag_list = ["Tag1"] if story.tag_list.empty?

    image1 = create_valid_image(attachment: fixture_file('story_image.jpg'))
    image1.crops.create!(usage: 'featured:5:3', top: 10, left: 10, width:50, height:30)
    story.images = [image1]
    story.set_published_and_save

    story
  end

  def new_valid_category(attrs = {})
    attrs.reverse_merge!(name: Faker::Name.name)
    Category.new(attrs)
  end

  def create_valid_category(attrs = {})
    category = new_valid_category(attrs)
    category.save!
    category
  end

  def create_valid_page(attrs = {})
    title = attrs[:title] || Faker::Name.name
    category = create :category, name: title
    category.page
  end

  def create_valid_template(attrs = {})
    attrs.reverse_merge!(name: Faker::Name.name)
    template = Template.new(attrs)
    template.save!
    template
  end

  def create_valid_region(attrs = {})
    attrs.reverse_merge!(name: Faker::Name.name)
    region = Region.new(attrs)
    region.save!
    region
  end

  def create_valid_area(attrs = {})
    area = Area.new(attrs)
    area.save!
    area
  end

  def create_valid_shared_area(attrs = {})
    attrs.reverse_merge!(shared: true)
    create_valid_area(attrs)
  end

  def create_valid_block(attrs = {})
    attrs.reverse_merge!(sort_order: 'created_at ASC', name: Faker::Name.name, content_type: 'headlines')
    block = Block.new(attrs)
    block.save!
    block
  end

  def create_valid_shared_block(attrs = {})
    attrs.reverse_merge!(sort_order: 'created_at ASC', name: Faker::Name.name, content_type: 'headlines')
    block = Block.new(attrs)
    block.shared = true
    block.save!
    block
  end

  def new_valid_image(attrs = {})
    attrs.reverse_merge!(attachment: fixture_file('story_image.jpg'), caption: "image caption", author: "Helmut Newton", agency: "gettyimages")
    image = Image.new(attrs)
    image
  end

  def create_valid_image(attrs = {})
    image = new_valid_image(attrs)
    image.save!
    image
  end

  def new_valid_crop(attrs = {})
    attrs.reverse_merge!(usage: "featured:5:3", top: 0, left: 0, height: 50, width: 30)
    Crop.new(attrs)
  end

  def create_valid_crop(attrs = {})
    crop = new_valid_crop(attrs)
    crop.save!
    crop
  end


  def new_valid_container(attrs = {})
    attrs.reverse_merge!(region_id: 1, area_id: 1)
    Container.new(attrs)
  end

  def create_valid_container(attrs = {})
      container = new_valid_container(attrs)
      container.save!
      container
  end

  def new_valid_tag(attrs = {})
    attrs.reverse_merge!(name: Faker::Name.name)
    ActsAsTaggableOn::Tag.new(attrs)
  end

  def create_valid_tag(attrs = {})
      tag = new_valid_tag(attrs)
      tag.save!
      tag
  end

  def new_valid_property_type(attrs = {})
    attrs.reverse_merge!(name: Faker::Name.name, story_type: "NewsStory")
    PropertyType.new(attrs)
  end

  def create_valid_property_type(attrs = {})
    property_type = new_valid_property_type(attrs)
    property_type.save!
    property_type
  end

  def new_valid_editorial_version(attrs = {})
    attrs.reverse_merge!(
      title: Faker::Name.name,
      subtitle: Faker::Name.name,
      excerpt: Faker::Name.name,
      body: Faker::Name.name,
      type_version: 'Tablet',
      story_id: create_valid_story.id
    )
    EditorialVersion.new(attrs)
  end

  def create_valid_editorial_version(attrs = {})
    editorial_version = new_valid_editorial_version(attrs)
    editorial_version.save!
    editorial_version
  end

  def create_valid_headline(attrs = {})
    attrs.reverse_merge!(
      title: Faker::Name.name,
      url: 'http://www.example.com'
    )

    headline = Headline.new (attrs)
    headline.save!
    headline
  end

  def create_valid_story_template(attrs = {})
    attrs.reverse_merge!(
      name: 'some_story_template',
      filename: 'some_story_template.html'
    )
    StoryTemplate.create!(attrs)
  end

  def create_valid_headline_block
    block = create_valid_block
    block.resume!
    category = create_valid_category(name: "Royal")
    block.categories << category

    story = create_published_story(title: "Queen Elizabeth is bored", category: category)

    block
  end

end

RSpec.configuration.include FactoryHelpers #, type: [:request, :models]
