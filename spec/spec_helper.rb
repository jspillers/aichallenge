require 'rubygems'
require 'rspec'

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false

  config.before :suite do
  end

  config.before(:each) do
  end

  config.after(:each) do
  end
end

