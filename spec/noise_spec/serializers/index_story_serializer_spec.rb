require 'spec_helper'

describe IndexStorySerializer do
  describe "prepares the story representation to be indexed" do
    before(:each) do
      @category = create_valid_category
      
      property_type1 = create_valid_property_type(name: "news_story_property_type1", story_type: "NewsStory")
      property_type2 = create_valid_property_type(name: "news_story_property_type2", story_type: "NewsStory")

      @story =  create_valid_story(category: @category, title:'The Queen Mother rises from the grave', pageid: 'XYZ', pageid_name: 'ZXY')

      @story.set_published_and_save
      
      @people = ['Person 1', 'Person 2']
      @places = ['Place 1', 'Place 2']
      @story.person_list = @people
      @story.place_list = @places

      @story.properties[0].value = 'value'
      @story.properties[1].value = nil

      @story_as_json = IndexStorySerializer.new(@story).as_json
    end
    
    it "exposes the id along with the publication" do
      @story_as_json[:id].should == "#{@story.id}-#{PUBLISH_CONFIG[:publication_name]}"
    end

    it "exposes the publication" do
      @story_as_json[:publication].should == PUBLISH_CONFIG[:publication_name]
    end

    it "exposes its title" do
      @story_as_json[:title].should == @story.title
    end
    
    it "exposes its subtitle" do
      @story_as_json[:subtitle].should == @story.subtitle
    end
    
    it "exposes its url" do
      @story_as_json[:url].should == @story.slug
    end
        
    it "exposes its formatted datetime" do
      @story_as_json[:story_datetime].should == 
        @story.published_at.strftime(IndexStorySerializer::DATETIME_FORMAT)
    end
    
    it "exposes its story type" do
      @story_as_json[:story_type].should == @story.story_type.underscore
    end

    it "exposes its content" do
      @story_as_json[:content].should == @story.body
    end

    it "exposes its section" do
      @story_as_json[:section].should == @story.category.name.downcase
    end

    it "exposes its tags" do
      @story_as_json[:tags].should == @people.concat(@places)
    end

    context "metadata" do
      it "the names contain imagenes" do
        @story_as_json[:metadata_names][0].should == 'imagenes'
      end

      it "the values contain the crops" do
        image1 = create_valid_image
        image2 = create_valid_image
        
        image1.crops.create!(usage: "featured:5:3", top: 0, left: 0, width: 50, height: 30)
        @story.images = [image1, image2]
        
        story = IndexStorySerializer.new(@story).as_json
        story[:metadata_values][0].should == @story.crops.as_json
      end

      it "the names contain publication" do
        @story_as_json[:metadata_names][1].should == 'publication'
      end

      it "the values contain the publication name value" do
        @story_as_json[:metadata_values][1].should == PUBLISH_CONFIG[:publication_name]
      end

      it "the names contain the property types" do
        @story_as_json[:metadata_names][2].should == 'news_story_property_type1'
      end

      it "the names does not contain the property types for empty properties" do
        @story_as_json[:metadata_names][3].should be_nil
      end


      it "the values contain the property values" do
        @story.properties.each_with_index do |property, i|
          @story_as_json[:metadata_values][2 + i].should == property.value
        end
      end
    end

    it "exposes its description" do
      @story_as_json[:description].should == @story.excerpt
    end
  end
end
