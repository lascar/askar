require 'spec_helper'

describe StringUtils do
  describe "#partitioned_name" do
    it "returns the md5 hash of the input string with dir separators" do
      input = "test"
      md5 = Digest::MD5.hexdigest(input)

      expect(subject.partitioned_name(input)).to eql File.join(md5.scan(/[a-z0-9]{2}/))
    end
  end

  describe '#insert_subdomain' do
    it 'inserts the given subdomain in the given uri' do
      uri = 'http://example.com'
      subdomain = 'testing'

      expect(subject.insert_subdomain(uri, subdomain)).to eql 'http://testing.example.com'
    end

    it 'returns the given uri if something goes wrong' do
      uri= nil
      subdomain = 'testing'

      expect(subject.insert_subdomain(uri, subdomain)).to eql uri
    end

    it 'returns the given uri for empty subdomain' do
      uri= 'http://a.proper.uri'
      subdomain = nil

      expect(subject.insert_subdomain(uri, subdomain)).to eql uri
    end

  end
end
