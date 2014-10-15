require 'spec_helper'

describe SolrIndexManager do
  let(:manager) { SolrIndexManager.new }
  let(:server) { double("Server") }

  before(:each) do
    RSolr.should_receive(:connect).
      with(url: PUBLISH_CONFIG[:solr_indexer_url]).
      and_return(server)
  end

  it "has a default server property" do
    manager.server.should == server
  end

  describe "#add_document" do
    before(:each) do
      @story = double("Story")
      @story_hash_for_index = double("StoryHash")
      
      IndexStorySerializer.stub_chain(:new, :as_json).
        and_return(@story_hash_for_index)
    end

    it "adds the serialized document to de index" do
      server.should_receive(:add).
        with(@story_hash_for_index, add_attributes: {commitWithin: 1000})

      manager.add_document(@story)
    end

    it "captures posible exceptions" do
      server.should_receive(:add).and_raise(Exception)
      
      expect { manager.add_document(@story) }.not_to raise_error
    end
  end
end
