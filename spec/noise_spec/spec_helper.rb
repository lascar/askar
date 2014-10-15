# Figure out where we are being loaded from
# If you got a big project, there is a chance that the spec_helper will be
# required in a many different ways: File.expand_path, File.join, etc.,— which
# results in it being loaded several times and it slows down your test suite!
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    fail 'foo'
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec/spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start('rails')
ENV['COVERAGE_STARTED'] = 'true'

# if ENV['COVERAGE']
#   puts 'Running specs with simplecov enabled...'
#   require 'simplecov'
#   require 'simplecov-rcov'
#
#   #:nodoc
#   module SimpleCov
#     module Formatter
#       #:nodoc
#       class MergedFormatter
#         def format(result)
#           SimpleCov::Formatter::HTMLFormatter.new.format(result)
#           SimpleCov::Formatter::RcovFormatter.new.format(result)
#         end
#       end
#     end
#   end
#   SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
#   SimpleCov.start 'rails' do
#     add_filter '/vendor/'
#   end
# end

require 'rubygems'
require 'spork'
require 'spork/ext/ruby-debug'
require 'sass'
require 'factory_girl'
require 'pry'

# uncomment the following line to use spork with the debugger
# require 'spork/ext/ruby-debug'

Spork.prefork do
  # SELENIUM_SERVER is the IP address or hostname of the system running Selenium
  # Server, this is used to determine where to connect to when using one of the
  # selenium_remote_* drivers
  SELENIUM_SERVER_HOST = ENV['SELENIUM_SERVER_HOST'] || '10.0.2.3'
  SELENIUM_SERVER_PORT = ENV['SELENIUM_SERVER_PORT'] || '4444'

  # SELENIUM_APP_HOST is the IP address or hostname of this system (where the
  # tests run against) as reachable for the SELENIUM_SERVER. This is used to set
  # the Capybara.app_host when using one of the selenium_remote_* drivers
  SELENIUM_APP_HOST = ENV['SELENIUM_APP_HOST'] || '33.33.33.66'
  SELENIUM_APP_PORT = ENV['SELENIUM_APP_PORT'] || '31337'
  # CAPYBARA_DRIVER is the Capybara driver to use, this defaults to Selenium with
  # Firefox
  CAPYBARA_BROWSER = ENV['CAPYBARA_DRIVER'] || 'firefox'
  SELENIUM_REMOTE_BROWSER = 'selenium_remote_' + CAPYBARA_BROWSER

  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV['RAILS_ENV'] = 'test'

  require 'rack_session_access'
  require 'ffaker'

  require File.expand_path('../dummy/config/environment.rb',  __FILE__)

  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rspec'
  require 'rack_session_access/capybara'
  require 'timecop'
  require 'webmock/rspec'
  require 'database_cleaner'
  require 'selenium-webdriver'

  # At this point, Capybara.default_driver is :rack_test, and
  # Capybara.javascript_driver is :selenium. We can't run :selenium in the Vagrant box,
  # so we set the javascript driver to :selenium_remote_firefox which we're going to
  # configure.
  Capybara.javascript_driver = SELENIUM_REMOTE_BROWSER
  Rails.backtrace_cleaner.remove_silencers!

  # Load support files
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    config.include HelperMethods::Controller, type: :controller
    config.include HelperMethods::Feature, type: :feature

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    # we use database_cleaner
    config.use_transactional_fixtures = false

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.fail_fast = false
    # config.order = "random"

    prefixes = [
      Publisher.first_publish_path,
      Publisher.first_preview_path,
      Rails.configuration.internal_publication_path
    ]

    config.before(:all) do
      Template.create(name: 'Category Page')
      Template.create(name: 'Tag Page')

      Rails.logger.debug "Cleaning up publish/preview artifacts from #{prefixes}"
      prefixes.each {|path| FileUtils.rmtree path}
    end

    config.after(:all) do
      Template.where(name: 'Category Page').destroy_all
      Template.where(name: 'Tag Page').destroy_all

      Rails.logger.debug "Cleaning up publish/preview artifacts from #{prefixes}"
      prefixes.each {|path| FileUtils.rmtree path}

      dragonfly_path = File.join(Rails.root, "public", "system")
      Rails.logger.debug "Cleaning up dragonfly artifacts from #{dragonfly_path}"
      FileUtils.rmtree dragonfly_path
    end

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      FactoryGirl.lint
    end

    config.after(:suite) do
      defined?(Capybara.current_session.driver.browser.close) && Capybara.current_session.driver.browser.close
    end

    config.before(:each) do
      TaggingService.stub!(:classify).and_return(Hash.new { |hash, key| hash[key] = [] })
      MiniExiftool.stub!(:new).and_return({})

      prefixes = [Publisher.first_publish_path, Publisher.first_preview_path, Rails.configuration.internal_publication_path].uniq
      Rails.logger.debug "Cleaning up publish/preview artifacts from #{prefixes}"
      prefixes.each {|path| FileUtils.rmtree path}
      WebMock.enable!
      if selenium_remote?
        WebMock.disable!
        Capybara.server_host = SELENIUM_APP_HOST
        Capybara.server_port = SELENIUM_APP_PORT
        Capybara.app_host = "http://#{SELENIUM_APP_HOST}:#{SELENIUM_APP_PORT}"
        visit '/en/login'
        browser = Capybara.current_session.driver.browser
        if defined? COOKIES
          browser.manage.add_cookie( name: COOKIES[:name], value: COOKIES[:value], path: "/", domain: SELENIUM_APP_HOST, expires: nil, secure: false )
        else
          fill_in 'Username', with: 'maintenance'
          fill_in 'Password', with: 'maintenance'
          click_button 'Log in'
          browser = Capybara.current_session.driver.browser
          COOKIES = browser.manage.all_cookies.first
        end
      end
    end

    config.after(:each) do
      if selenium_remote?
        DatabaseCleaner.strategy = :transaction
        DatabaseCleaner.clean_with(:truncation, :except => %w[templates])
      end
      Capybara.use_default_driver
      Capybara.app_host = nil
      Capybara.server_host = '127.0.0.1'
      Capybara.server_port = nil
    end

  # Determines if a selenium_remote_* driver is being used
  def selenium_remote?
    !(Capybara.current_driver.to_s =~ /\Aselenium_remote/).nil?
  end

    config.around(:each) do |example|
      # Use really fast transaction strategy for all
      # examples except `js: true` capybara specs
      # DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
      DatabaseCleaner.strategy = :truncation, {:except => %w[templates]}

      # Start transaction
      DatabaseCleaner.start

      # Run example
      example.run

      # Rollback transaction
      DatabaseCleaner.clean
    end

  end

  Capybara.configure do |config|
    config.default_wait_time = 5
    config.match = :prefer_exact
    config.ignore_hidden_elements = false
    config.visible_text_only = false
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

  FactoryGirl.reload
end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.

# CapybaraDriverRegistrar is a helper class that enables you to easily register
# Capybara drivers
class CapybaraDriverRegistrar
  def self.register_selenium_remote_driver(browser)
    capabilities = Selenium::WebDriver::Remote::Capabilities.new
    capabilities['browser'] = browser
    capabilities['browserName'] = browser
    capabilities['browserVersion'] = 'ANY'
    capabilities['platform'] = 'ANY'
    capabilities['version'] = 'ANY'
    capabilities['javascriptEnabled'] = 'true'
    Capybara.register_driver SELENIUM_REMOTE_BROWSER  do |app|
      Capybara::Selenium::Driver.new(app, browser: :remote, url: "http://#{SELENIUM_SERVER_HOST}:#{SELENIUM_SERVER_PORT}/wd/hub", desired_capabilities: capabilities)
    end
  end
end

# Register various Selenium drivers
CapybaraDriverRegistrar.register_selenium_remote_driver(CAPYBARA_BROWSER)
