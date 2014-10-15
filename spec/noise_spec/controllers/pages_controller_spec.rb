require 'spec_helper'

describe PagesController, type: :controller do
  describe '#preview' do
    before(:each) do
      Page.stub(:find).and_return(page)
    end
    context 'logged user' do
      subject { get :preview, id: page.id }
      before(:each) do
        login_as('user', 'editor')
      end
      context 'home page' do
        let(:category) { create(:category, :home) }
        let(:page) { category.page }
        before(:each) do
          @url = PUBLISH_CONFIG[:preview_host]
        end
        it 'redirects_to valid preview url' do
          subject.should redirect_to(@url)
        end
      end
      context 'regular page' do
        let(:page) { create(:category).page }
        before(:each) do
          @url = "#{PUBLISH_CONFIG[:preview_host]}/#{page.slug}"
        end
        it 'redirects_to valid preview url' do
          subject.should redirect_to(@url)
        end
      end
      context 'subcategory page' do
        let(:category1) { create(:category) }
        let(:category2) { create(:category, parent: category1) }
        let(:page) { category2.page }
        before(:each) do
          slug1 = category1.name.parameterize
          slug2 = category2.name.parameterize
          @url = "#{PUBLISH_CONFIG[:preview_host]}/#{slug1}/#{slug2}"
        end
        it 'redirects_to valid preview url' do
          subject.should redirect_to(@url)
        end
      end
      context 'subdomain page' do
        let(:category) { create(:category, :with_subdomain) }
        let(:page) { category.page }
        before(:each) do
          host = PUBLISH_CONFIG[:preview_host]
          subdomain = category.related_subdomain
          prefix_url = StringUtils.new.insert_subdomain(host, subdomain)
          @url = "#{prefix_url}/#{page.slug}"
        end
        it 'redirects_to valid preview url' do
          subject.should redirect_to(@url)
        end
      end
      context 'subdomain subcategory page' do
        let(:category1) { create(:category, :with_subdomain) }
        let(:category2) do
          create(:category, :with_subdomain,
                 parent: category1,
                 related_subdomain: category1.related_subdomain)
        end
        let(:page) { category2.page }
        before(:each) do
          slug1 = category1.name.parameterize
          slug2 = category2.name.parameterize
          host = PUBLISH_CONFIG[:preview_host]
          subdomain = category1.related_subdomain
          prefix_url = StringUtils.new.insert_subdomain(host, subdomain)
          @url = "#{prefix_url}/#{slug1}/#{slug2}"
        end
        it 'redirects_to valid preview url' do
          subject.should redirect_to(@url)
        end
      end
      context 'tag page' do
        let(:page) { create :tag_page }
        before(:each) do
          host = PUBLISH_CONFIG[:preview_host]
          prefix = PUBLISH_CONFIG[:publication_url_prefix_id]
          @url = "#{host}/tags/#{prefix}/#{page.slug}"
        end
        it 'redirects_to valid preview url' do
          subject.should redirect_to(@url)
        end
      end
      context 'home tag page' do
        let(:page) { create(:tag_page, :slug_home) }
        before(:each) do
          host = PUBLISH_CONFIG[:preview_host]
          prefix = PUBLISH_CONFIG[:publication_url_prefix_id]
          @url = "#{host}/tags/#{prefix}/"
        end
        it 'redirects_to valid preview url' do
          subject.should redirect_to(@url)
        end
      end
      context 'default tag page' do
        let(:page) { create :default_tag_page }
        before(:each) do
          @url = "#{PUBLISH_CONFIG[:preview_host]}/#{page.slug}"
        end
        it 'redirects_to valid preview url' do
          subject.should redirect_to(@url)
        end
      end
    end
  end
end
