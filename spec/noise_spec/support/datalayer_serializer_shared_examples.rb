shared_examples "a dataLayer serializer" do |object|
  let(:base_object) { object || double(read_attribute_for_serialization: true)}
  let(:serialized_object) { described_class.new(base_object).as_json }

  it 'exposes the publication' do
    expect(serialized_object[:publication]).to eql PUBLISH_CONFIG[:publication_name]
  end
  
  it "exposes the subdomain" do
    expect(serialized_object[:subdomain]).to eql 'generico'
  end
  
  it "exposes its country_edition" do
    expect(serialized_object[:country_edition]).to eql 'ca'
  end
  
  it "exposes its editorial_group" do
    expect(serialized_object[:editorial_group]).to eql serialized_object[:publication]
  end
  
  it "exposes its comscore_group" do
    expect(serialized_object[:comscore_group]).to eql ''
  end
end
