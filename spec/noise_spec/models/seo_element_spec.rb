require 'spec_helper'

describe SeoElement do

  describe "#as_json" do

    before(:each) do
      story = create_valid_story
      @seo_element = story.seo_element
      @seo_element.url_base = 'url_base'
      @seo_element.redirection = 'redirection'
      @seo_element.canonical = 'canonical'
      @seo_element_as_json = @seo_element.as_json
    end

    it "exposes its meta_title" do
      @seo_element_as_json[:meta_title].should == @seo_element.meta_title
    end

    it "exposes its meta_description" do
      @seo_element_as_json[:meta_description].should == @seo_element.meta_description
    end

    it "exposes its meta_keywords" do
      @seo_element_as_json[:meta_keywords].should == @seo_element.meta_keywords
    end

    it "exposes its url_base" do
      @seo_element_as_json[:url_base].should == @seo_element.url_base
    end

    it "exposes its redirection" do
      @seo_element_as_json[:redirection].should == @seo_element.redirection
    end

    it "exposes its canonical" do
      @seo_element_as_json[:canonical].should == @seo_element.canonical
    end
    
  end
end
