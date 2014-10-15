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

AUTHORIZATION_CONFIG = YAML.load(File.read(File.expand_path('../../authorization.yml', __FILE__)))
AUTHORIZATION_CONFIG.recursive_symbolize_keys!
AUTHORIZATION_CONFIG.merge! AUTHORIZATION_CONFIG.fetch(Rails.env.to_sym, {})
