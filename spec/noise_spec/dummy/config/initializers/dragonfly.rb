require 'dragonfly/rails/images'

app = Dragonfly[:images]
app.configure do |c|
  # c.url_format = '/images/:job/:basename.:format'
end

#
# Enable non-verbose Rack::Cache in dev/test (https://github.com/markevans/dragonfly/issues/159)
#
if Rails.env.development? || Rails.env.test?
  Rails.application.middleware.delete Rack::Cache
  Rails.application.middleware.insert 0, Rack::Cache, {
    :verbose     => false,
    :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
    :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
  }
end