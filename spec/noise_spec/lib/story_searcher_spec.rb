require 'spec_helper'

describe StorySearcher do

  describe "advanced_search" do

    before(:each) do
      @royalty = create_valid_category(name: 'Royalty')
      @food    = create_valid_category(name: 'Food')

      @tag_retro = create_valid_tag(name: 'retro')
      @tag_fashion = create_valid_tag(name: 'fashion')

      @story_apples = create_valid_story(title: "Crunch time for cooking with apples",
        excerpt: "They make for the perfect ingredient for delicious recipes and along them comes a number of health benefits.",
        body: "And with apples of different textures, colours, tastes, shapes and sizes there is undoubtedly an apple out there for everyone.",
        category: @food,
        creator: 'user1')

      @story_indian = create_valid_story(title: "Indian Superspices",
        excerpt: "The key to fighting cold and flu this winter.",
        body: "Although there is a worldwide love of Indian spice in the kitchen, it has also long been used in an ancient system of medical care known as Ayurveda.",
        creator: 'user1')
      @story_indian.secondary_categories = [@food]

      @story_royal = create_valid_story(title:'The Queen Mother rises from the grave',
        excerpt: "The zombie invasion.",
        body: "Just your run of the mill zombie attack.",
        creator: 'user2')
      @story_royal.secondary_categories = [@royalty]
      @story_royal.update_attribute(:first_published_at, DateTime.new(2012, 10, 10))

      @story_cake = create_valid_story(title: "A wonderful cheese cake",
        excerpt: "Baking a cake",
        body: "But for a twist on the traditional formula, add seasonal fruits such as apples and berries.",
        story_type: 'Recipe',
        tag_list: "#{@tag_retro.name}, #{@tag_fashion.name}",
        creator: 'user2')
      @story_cake.update_attribute(:first_published_at, DateTime.new(2012, 9, 25, 14, 53))
      @story_cake.update_attribute(:published_at, DateTime.new(2012, 10, 25, 10, 23))

      @property_type = create_valid_property_type(name: "nickname", story_type: "Biography")
      @story_bio = create_valid_story(title: "Peter Parker biography",
        excerpt: "With great power there must also come great responsibility",
        body: "Over the years, the Peter Parker character has developed from shy, nerdy high school student to troubled but outgoing college student.",
        story_type: 'Biography')
      @story_bio.properties.find_by_property_type_id(@property_type.id).update_attribute(:value, "Spiderman")
    end

    it "finds stories by text in title, excerpt or body" do
      query = {text_search: 'apples'}
      results = StorySearcher.advanced_search(query)
      results.should include(@story_apples)
      results.should_not include(@story_indian)
    end

    it "finds stories by category" do
      query = {q: {categorisations_category_id_or_categorisation_category_id_eq: @food.id }}
      results = StorySearcher.advanced_search(query)
      results.should include(@story_apples)
      results.should include(@story_indian)
      results.should_not include(@story_royal)
    end

    it "finds stories by tag" do
      query = {q: {tags_id_eq: @tag_fashion.id }}
      results = StorySearcher.advanced_search(query)
      results.should include(@story_cake)
      results.should_not include(@story_apples)
      results.should_not include(@story_indian)
      results.should_not include(@story_royal)
    end

    it "finds stories by user" do
      query = {q: {creator_eq: 'user1'}}
      results = StorySearcher.advanced_search(query)
      results.should include(@story_apples)
      results.should include(@story_indian)
      results.should_not include(@story_royal)
      results.should_not include(@story_cake)
    end

    it "finds stories by first publication date" do
      query = {q: {first_published_at_as_date_dategteq: DateTime.new(2012, 9, 24),
                   first_published_at_as_date_datelteq: DateTime.new(2012, 9, 27)}}
      results = StorySearcher.advanced_search(query)
      results.should include(@story_cake)
      results.should_not include(@story_apples)
      results.should_not include(@story_indian)
      results.should_not include(@story_royal)
    end

    it "finds stories by story type" do
      query = {q: {story_type_eq: 'Recipe'}}
      results = StorySearcher.advanced_search(query)
      results.should include(@story_cake)
      results.should_not include(@story_apples)
      results.should_not include(@story_indian)
      results.should_not include(@story_royal)
    end

    context "finds stories by properties" do
      it "with story_type" do
        query = {q: {story_type_eq: 'Biography'}, p: {@property_type.id => 'Spiderman'}}
        results = StorySearcher.advanced_search(query)
        results.should include(@story_bio)
        results.should_not include(@story_apples)
        results.should_not include(@story_indian)
        results.should_not include(@story_royal)
        results.should_not include(@story_cake)
      end
      it "without story_type set" do
        query = {p: {@property_type.id => 'Spiderman'}}
        results = StorySearcher.advanced_search(query)
        results.should include(@story_bio)
        results.should_not include(@story_apples)
        results.should_not include(@story_indian)
        results.should_not include(@story_royal)
        results.should_not include(@story_cake)
      end
    end

    it 'shorts results by descendent date' do
      @story_apples.update_attribute(:updated_at, @story_apples.updated_at - 1.days)
      @story_cake.update_attribute(:updated_at, @story_cake.updated_at - 2.days)
      query = {text_search: 'a'}
      results = StorySearcher.advanced_search(query)
      expect(results[0]).to eql(@story_indian)
      expect(results[1]).to eql(@story_apples)
      expect(results[2]).to eql(@story_cake)
    end
  end

  describe "#related_stories_search" do
    it "doesn't include story in results" do
      story = create_valid_story
      StorySearcher.related_stories_search({}, story).should_not include(story)
    end
    it "doesn't include related stories in results" do
      story = create_valid_story
      related_story = create_published_story
      story.headlines.create!(linked: true, story: related_story)

      StorySearcher.related_stories_search({}, story).should_not include(related_story)
    end
  end

end
