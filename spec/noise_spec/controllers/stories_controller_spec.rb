require 'spec_helper'

describe StoriesController, type: :controller do

  describe '#index' do
    include_context 'all kinds of stories'

    context 'anonymous user' do
      it 'redirects to login page' do
        get :index
        expect_login_redirect
      end
    end
    context 'no search params' do
      context 'logged user' do
        before(:each) do
          login_as('user', 'editor')
          get :index
        end
        it 'returns published stories owned by current user' do
          expect(response.status).to eq(200)
          assigns(:stories_published).should match_array(@published_by_user)
        end
        it 'returns all recent published stories' do
          expect(response.status).to eq(200)
          assigns(:stories_published_all).should match_array(all_published)
        end
      end
      context 'editor user' do
        before(:each) do
          login_as('user', 'editor')
          get :index
        end
        it 'returns draft stories owned by current user' do
          expect(response.status).to eq(200)
          assigns(:stories_drafts).should match_array(@drafts_by_user)
        end
      end
      context 'admin user' do
        before(:each) do
          login_as('user', 'admin')
          get :index
        end
        it 'returns all recent draft stories' do
          expect(response.status).to eq(200)
          assigns(:stories_drafts).should match_array(all_drafts)
        end
      end
    end
  end

  describe "#update" do
    before(:each) do
      login_as('user', 'reporter')
      @story = create_valid_story
      @params_with_seo_fields = {id: @story.id, story: {title: 'lololo', seo_element_attributes: {meta_title: 'lololo_meta', canonical: 'http://canonical.url'}}}
    end

    context "without seo role" do
      it "doesn't update the seo fields" do
        request.env["HTTP_REFERER"] = edit_story_url(@story)
        controller.should_not_receive(:remove_url_seo_elements)
        put :update, @params_with_seo_fields
      end
    end

    context "with seo role" do
      it "updates the seo fields" do
        login_as('user', 'seo')
        request.env['HTTP_REFERER'] = edit_story_url(@story)
        put :update, { id: @story.id, params: @params_with_seo_fields }
        controller.should_not_receive(:remove_url_seo_elements)
      end
    end
  end

  describe "remove_url_seo_elements" do
    before(:each) do
      login_as('user', 'reporter')
      @story = create_valid_story
      @params_with_seo_fields = {id: @story.id, story: {title: 'lololo', seo_element_attributes: {meta_title: 'lololo_meta', canonical: 'http://canonical.url'}}}

      controller.send(:remove_url_seo_elements, @params_with_seo_fields[:story])
    end
    it "removes canonical" do
      @params_with_seo_fields[:story][:seo_element_attributes][:canonical].should be_nil
    end
    it "doesn't remove meta_title" do
      @params_with_seo_fields[:story][:seo_element_attributes][:meta_title].should_not be_nil
    end
  end
end
