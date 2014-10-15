require 'spec_helper'

describe StoryDatalayerSerializer do
  before(:each) do
    @category = create_valid_category

    @story = create_valid_story(category: @category, story_type: 'MyStoryType')
    @story.set_published_and_save

    @serialized_story = StoryDatalayerSerializer.new(@story).as_json
  end
  
  context 'common fields' do
    it 'exposes the publication' do
      expect(@serialized_story[:publication]).to eql PUBLISH_CONFIG[:publication_name]
    end
    
    it 'exposes the subdomain' do
      expect(@serialized_story[:subdomain]).to eql 'generico'
    end
    
    it 'exposes its country_edition' do
      expect(@serialized_story[:country_edition]).to eql 'ca'
    end
    
    it 'exposes its editorial_group' do
      expect(@serialized_story[:editorial_group]).to eql @serialized_story[:publication]
    end
    
    it 'exposes its comscore_group' do
      expect(@serialized_story[:comscore_group]).to eql ''
    end
  end

  context 'content dependent fields' do
    it 'exposes the section' do
      expect(@serialized_story[:section]).to eql @category.path_slug
    end
    
    context 'subsection' do
      it 'exposes the field for parent categories' do
        expect(@serialized_story[:subsection]).to eql "#{@category.path_slug}/news"
      end
      
      it 'exposes the field for child categories' do
        category = create_valid_category(parent_id: @category.id)
        story = create_valid_story(category: category)
        story.set_published_and_save
        serialized_story = StoryDatalayerSerializer.new(story).as_json
        
        expect(serialized_story[:subsection]).to eql category.path_slug
      end
    end
    
    it 'exposes the document_type' do
      expect(@serialized_story[:document_type]).to eql 'MyStoryType'
    end
    
    it 'exposes the publication_date' do
      expect(@serialized_story[:publication_date]).to eql @story.published_at.strftime(DatalayerSerializer::DATE_FORMAT)
    end
  end
end
