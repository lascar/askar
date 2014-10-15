class Hash
  def recursive_symbolize_keys!
    symbolize_keys!
    # symbolize each hash in .values
    values.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    # symbolize each hash inside an array in .values
    values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end
end

PUBLISH_CONFIG = YAML.load(File.read(File.expand_path('../../publish.yml', __FILE__)))
PUBLISH_CONFIG.recursive_symbolize_keys!
PUBLISH_CONFIG.merge! PUBLISH_CONFIG.fetch(Rails.env.to_sym, {})
