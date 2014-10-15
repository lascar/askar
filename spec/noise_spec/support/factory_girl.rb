module FactoryGirl
  module Helper
    module Methods
      def create_list(factory, size, options)
        build_list(factory, size).each do |model|
          options.each do |key, value|
            model.send("#{key}=", value)
            model.save!
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include FactoryGirl::Helper::Methods

  config.before(:suite) do
    FactoryGirl.lint
  end
end
