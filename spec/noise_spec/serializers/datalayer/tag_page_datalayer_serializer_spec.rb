require 'spec_helper'

describe TagPageDatalayerSerializer do

  before(:each) do
    template = create_valid_template
    @page = create_valid_page(template: template)
    @page.pageable = create_valid_tag
    @serialized_object = TagPageDatalayerSerializer.new(@page).as_json
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
  
  it 'exposes the section' do
    expect(@serialized_object[:section]).to eql 'tags'
  end
  
  it 'exposes the subsection' do
    expect(@serialized_object[:subsection]).to eql ''
  end
  
  it 'exposes the document_type' do
    expect(@serialized_object[:document_type]).to eql 'Tags'
  end

  it 'exposes the content_type' do
    expect(@serialized_object[:content_type]).to eql ''
  end

  it 'exposes the publication_date' do
    expect(@serialized_object[:publication_date]).to eql @page.updated_at.strftime(DatalayerSerializer::DATE_FORMAT)
  end
end
