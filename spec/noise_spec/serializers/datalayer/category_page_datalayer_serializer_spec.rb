require 'spec_helper'

describe CategoryPageDatalayerSerializer do

  before(:each) do
    @category = create_valid_category

    @page = @category.page

    @serialized_object = CategoryPageDatalayerSerializer.new(@page).as_json
  end
  
  context 'common fields' do
    it 'exposes the publication' do
      expect(@serialized_object[:publication]).to eql PUBLISH_CONFIG[:publication_name]
    end
    
    it 'exposes the subdomain' do
      expect(@serialized_object[:subdomain]).to eql 'generico'
    end
    
    it 'exposes its country_edition' do
      expect(@serialized_object[:country_edition]).to eql 'ca'
    end
    
    it 'exposes its editorial_group' do
      expect(@serialized_object[:editorial_group]).to eql @serialized_object[:publication]
    end
    
    it 'exposes its comscore_group' do
      expect(@serialized_object[:comscore_group]).to eql ''
    end
  end
  
  it 'exposes the section for pageable objects' do
    expect(@serialized_object[:section]).to eql @category.path_slug
  end

  context 'subsecion' do
    it 'exposes the field for parent categories' do
      expect(@serialized_object[:subsection]).to eql "#{@category.path_slug}/cover"
    end
    
    it 'exposes the field for child categories' do
      childcat = create_valid_category(parent_id: @category.id)
      page = childcat.page
      serialized_object = described_class.new(page).as_json
        
      expect(serialized_object[:subsection]).to eql childcat.path_slug
    end

    it 'exposes the field for the home' do
      homecat = create_valid_category(name: 'HOME')
      page = homecat.page
      serialized_object = described_class.new(page).as_json
        
      expect(serialized_object[:subsection]).to eql "#{homecat.path_slug}/home"
    end
  end
  
  context 'non-pageable objects' do
    let(:default_tag_page) {Page.create!(slug: '/tags/default', title: "Default Tag Page", template: Template.create(name: "Default Tag Page"))}
    let(:serialized_object) {CategoryPageDatalayerSerializer.new(default_tag_page).as_json}

    it 'returns an empty string for non-pageable objects (ie. the default tag page)' do
      expect(serialized_object[:section]). to eql ''
    end

    it 'returns an empty string as subsection for non-pageable objects (ie. the default tag page)' do
      expect(serialized_object[:subsection]). to eql ''
    end
  end

  it 'exposes the document_type' do
    expect(@serialized_object[:document_type]).to eql 'Cover'
  end

  it 'exposes the publication_date' do
    expect(@serialized_object[:publication_date]).to eql @page.updated_at.strftime(DatalayerSerializer::DATE_FORMAT)
  end
end
