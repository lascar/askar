require 'spec_helper'

describe EditorialVersion do

  context '(for a story)'do
    before(:each) do
      @story = create_valid_story(title: 'The Queen Mother rises from the grave',
                          subtitle: "Cheeky monkey",
                          excerpt: 'Just your run of the mill royal zombie resurection incident',
                          body: 'Just your run of the mill royal')

      @editorial_version = EditorialVersion.new(type_version: 'Tablet')
      @editorial_version.story = @story
    end

    it 'should inherit the title form the story' do
      @editorial_version.title.should == 'The Queen Mother rises from the grave'
    end

    it 'should inherit the subtitle form the story' do
      @editorial_version.subtitle.should == 'Cheeky monkey'
    end

    it 'should inherit the excerpt from the story' do
      @editorial_version.excerpt.should == 'Just your run of the mill royal zombie resurection incident'
    end

    it 'should inherit the body from the story' do
      @editorial_version.body.should == 'Just your run of the mill royal'
    end

    it 'can override the title it inherits' do
      @editorial_version.title = 'The Queen Mother is married once again'
      @editorial_version.save!
      @editorial_version.reload
      @editorial_version.title.should == 'The Queen Mother is married once again'
    end

    it 'can override the subtitle it inherits' do
      @editorial_version.subtitle = 'You cheeky monkey'
      @editorial_version.save!
      @editorial_version.reload
      @editorial_version.subtitle.should == 'You cheeky monkey'
    end

    it 'can overrid the excerpt it inherits' do
      @editorial_version.excerpt = 'The last duke, enjoyed a long life'
      @editorial_version.save!
      @editorial_version.reload
      @editorial_version.excerpt.should == 'The last duke, enjoyed a long life'
    end
  end

  describe "#as_json" do
    before(:each) do
      @story = create_valid_story
      @type_version = 'Tablet'
      @editorial_version = EditorialVersion.new(type_version: 'Tablet')
      @editorial_version.story = @story
      @editorial_version_base = @editorial_version
    end
    
    context 'with changes from story' do
      %w[title excerpt body].each do |field|
        context "in #{field} field" do
          before(:each) do
            @editorial_version = @editorial_version_base
            @editorial_version.send("#{field}=", "new value")
          end
          
          it "exposes its type_version" do
            @editorial_version.as_json[:type_version].should == @type_version 
          end
          
          it "exposes its title" do
            @editorial_version.as_json[:title].should == @editorial_version.title
          end

          it "exposes its subtitle" do
            @editorial_version.as_json[:subtitle].should == @editorial_version.subtitle
          end
          
          it "exposes its excerpt" do
            @editorial_version.as_json[:excerpt].should == @editorial_version.excerpt
          end
          
          it "exposes its body" do
            @editorial_version.as_json[:body].should == @editorial_version.body
          end
        end
      end
    end
  end

end
