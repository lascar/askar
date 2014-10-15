require 'spec_helper'

describe TaggingService do
  before(:each) do
    TaggingService.unstub!(:classify)
  end

  context "response parsing" do

    before(:each) do
      response = eval(File.read(fixture_file("tagging_service_response.rb")))
      TaggingService.should_receive(:post).and_return(response)
      @results = TaggingService.classify(title: 'Any', body: 'Any')
    end

    it "extracts hits.body.*.* to a two-level categories array" do
      @results[:categories].should == [["royalty", ["uk", "ireland"]], ["fashion", ["men's"]]]
    end

    it "extracts tags.entities.general.uncategorized to tags" do
      @results[:suggested_tags].should == ["Boris Johnson", "Ken Livingstone"]
    end

    it "extracts tags.entities.hits.uncategorized to tags" do
      @results[:tags].should == ["Awards", "Oscar"]
    end

    it "extracts tags.entities.hits.Lugares to places" do
      @results[:places].should == ['Belfast', 'Cardiff', 'London']
    end

    it "extracts tags.entities.hits.Personajes to people" do
      @results[:people].should == ['Prince Harry', 'Queen Elizabeth II']
    end

    it "extracts tags.entities.hits.Organismos to institutions" do
      @results[:institutions].should == ["Royal Navy", "Wales Office"]
    end

    it "extracts tags.entities.hits.Marcas to brands" do
      @results[:brands].should == ['Aston Martin', 'Bentley']
    end
    it "extracts tags.entities.hits.Lugares to places" do
      @results[:companies].should == ['BBC', 'Top Gear']
    end

  end

  context "move previously used tags to correct context" do
    before(:each) do
      @story = create_valid_story(person_list: "Boris Johnson, Oscar")
      response = eval(File.read(fixture_file("tagging_service_response.rb")))
      TaggingService.should_receive(:post).and_return(response)
      @results = TaggingService.classify(title: 'Any', body: 'Any')
    end

    it "moves tag to previously used context" do
      @results[:people].should include("Oscar")
      @results[:tags].should_not include("Oscar")
    end

    it "moves suggested tag to previously used context" do
      @results[:people].should include("Boris Johnson")
      @results[:suggested_tags].should_not include("Boris Johnson")
    end
  end

  context "move previously used tags to correct context for response (bug #537)" do
    before(:each) do
      create_valid_story(place_list: ['New York'], institution_list: ['The Tv'])
      @story = create_valid_story(tag_list: ['kim'])
      response = eval(File.read(fixture_file("tagging_service_response_2.rb")))
      TaggingService.should_receive(:post).and_return(response)
      @results = TaggingService.classify(title: 'Any', body: 'Any')
    end

    it "moves tag to previously used context not present in result set" do
      @results[:places].should include("New York")
      @results[:tags].should_not include("New York")
    end

    it "moves suggested tag to previously used context not present in result set" do
      @results[:institutions].should include("The Tv")
      @results[:suggested_tags].should_not include("The Tv")
    end
  end

  it "correctly handles an empty response" do
    response = eval(File.read(fixture_file("empty_tagging_service_response.rb")))
    TaggingService.should_receive(:post).and_return(response)
    @results = TaggingService.classify(title: 'Any', body: 'Any')

    @results[:categories].should be_blank
    @results[:tags].should be_blank
    @results[:places].should be_blank
    @results[:people].should be_blank
    @results[:institutions].should be_blank
    @results[:brands].should be_blank
    @results[:companies].should be_blank
  end

  context "server errors" do

    before(:each) do
      XMLRPC::Client.any_instance.should_receive(:call).and_raise(Exception)
    end

    it "returns blank results for all tagging contexts" do
      @results = TaggingService.classify(title: 'Any', body: 'Any')

      @results[:tags].should be_blank
      @results[:categories].should be_blank
      @results[:places].should be_blank
      @results[:people].should be_blank
      @results[:institutions].should be_blank
      @results[:brands].should be_blank
      @results[:companies].should be_blank
    end

    it "logs a warning" do
      Rails.logger.should_receive(:warn).with(/TaggingService/)
      TaggingService.classify(title: 'Any', body: 'Any')
    end

  end

end
