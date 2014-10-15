require 'spec_helper'

describe Page do

  before(:each) do
    @template = create_valid_template(name: 'Category Page')
  end

  it 'should be invalid without a template' do
    page = Page.new title: 'Royalty'
    page.template = nil
    page.should_not be_valid
    page.should have(1).error_on(:template)
  end

  it 'should be invalid without pageable (Category)' do
    page = Page.new title: 'Royalty', template: @template
    page.pageable_type = 'Category'
    page.should_not be_valid
    page.should have(1).error_on(:pageable_id)
  end

  it 'is created with a default set of publicity_formats' do
    page = Page.create! title: 'Test page', slug: '/slug', template: @template
    page.publicity_formats.should == [
      'top_990x90:4874',
      'robapaginas_300x250:4875'
    ]
  end

  describe '#publicity_formats_as_json' do
    let(:page) { create_valid_page }
    let(:publicity_formats_as_json) { page.publicity_formats_as_json }

    it 'exposes its publicity formats as a name/id Hash' do
      publicity_formats_as_json.should == [
        { name: 'top_990x90', id: '4874' },
        { name: 'robapaginas_300x250', id: '4875' }
      ]
    end
  end

  describe '#content_type' do

    before(:each) do
      @page = create_valid_page(template: @template)
    end

    it "returns 'Tag' when the pageable is a Tag" do
      @page.pageable = create_valid_tag

      @page.content_type.should == 'Tag'
    end

    it "returns 'Category' when the pageable is a Category" do
      @page.pageable = create_valid_category

      @page.content_type.should == 'Category'
    end

  end

  describe 'Newly created category page' do
    it 'has as many new areas as the number of template regions'
    it 'each area has a headline block where the source is the category'
  end

  describe 'Newly created tag page' do
    it 'has as many new areas as the number of template regions'
    it 'each area has a headline block where the source is the tag'
  end

  describe 'pageable uniqueness' do
    before(:each) do
      @page = create_valid_page(template_id: @template.id)
    end

    it 'pageable should be unique' do
      # with this there is already a default page related to category
      category = create_valid_category

      @page.pageable = category
      @page.should_not be_valid
      @page.should have(1).error_on(:pageable_id)
    end
  end

  describe '#as_json' do
    before(:each) do
      @category = create_valid_category
      @category.page.update_attributes(pageid: '<script>', pageid_name: 'XZVF')
      @page = @category.page
    end

    it 'exposes its slug' do
      @page.as_json[:page][:slug].should == @page.slug
    end

    it 'exposes its related regions' do
      @page.regions(true).each do |region|
        @page.as_json[region.name_for_json].should == region.as_json
      end
    end

    it 'exposes its template' do
      @page.as_json[:template].should == @page.template.as_json
    end

    it 'exposes its pageid' do
      @page.as_json[:pageid].should == '<script>'
    end

    it 'exposes its pageid_name' do
      @page.as_json[:pageid_name].should == 'XZVF'
    end

    it 'exposes its seo element' do
      @page.as_json[:seo_element].should == @page.seo_element.as_json
    end

    it "exposes its categorie's publicity formats as a name/id Hash" do
      @page.as_json[:publicity_formats].should == [
        { name: 'top_990x90', id: '4874' },
        { name: 'robapaginas_300x250', id: '4875' }
      ]
    end

    context 'datalayer' do
      it 'exposes the field for Category pages' do
        cat_serialized = { key: 'cat_value' }
        CategoryPageDatalayerSerializer.stub_chain(:new, :as_json)
          .and_return(cat_serialized)

        @page.as_json[:data_layer].should == cat_serialized
      end

      it 'exposes the field for Tag pages' do
        tag_serialized = { key: 'tag_value' }
        TagPageDatalayerSerializer.stub_chain(:new, :as_json)
          .and_return(tag_serialized)

        page = create_valid_page
        page.pageable = create_valid_tag

        page.as_json[:data_layer].should == tag_serialized
      end
    end
  end

  describe '#provides_image_rights?' do
    it 'should be false' do
      page = create_valid_page
      page.should_not be_provides_image_rights
    end
  end

  describe 'seo element' do
    it 'is not empty after page creation' do
      page = create_valid_page(template: @template)

      seo_element = page.seo_element

      seo_element.should_not be_nil
    end
  end

  describe '#preview_url' do
    context 'home page' do
      let(:category) { create(:category, :home) }
      let(:page) { category.page }
      before(:each) do
        @url = PUBLISH_CONFIG[:preview_host]
      end
      it 'redirects_to valid preview url' do
        expect(page.preview_url).to eql(@url)
      end
    end
    context 'regular page' do
      let(:page) { create(:category).page }
      before(:each) do
        @url = "#{PUBLISH_CONFIG[:preview_host]}/#{page.slug}"
      end
      it 'redirects_to valid preview url' do
        expect(page.preview_url).to eql(@url)
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
        expect(page.preview_url).to eql(@url)
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
        expect(page.preview_url).to eql(@url)
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
        expect(page.preview_url).to eql(@url)
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
        expect(page.preview_url).to eql(@url)
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
        expect(page.preview_url).to eql(@url)
      end
    end
    context 'default tag page' do
      let(:page) { create :default_tag_page }
      before(:each) do
        @url = "#{PUBLISH_CONFIG[:preview_host]}/#{page.slug}"
      end
      it 'redirects_to valid preview url' do
        expect(page.preview_url).to eql(@url)
      end
    end
  end
end
