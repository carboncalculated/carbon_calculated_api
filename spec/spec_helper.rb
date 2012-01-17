ENV["RACK_ENV"] ||= 'test'
project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

begin
  # Try to require the preresolved locked set of gems.
  require ::File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require(:default, :test)
require File.join(project_root, 'lib', 'carbon_calculated_api')

mongo_config = CarbonCalculatedApi.config.with_indifferent_access
MongoMapper.setup(mongo_config, ENV["RACK_ENV"])

require "validatable"
require 'machinist/mongo_mapper'

# == This is most definetly not a good approach; howevr I need to 
# create objects easily and the blueprint is the way forward to be 
# truly honest even thou the model from admin are in the support arhh
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
require File.expand_path(File.dirname(__FILE__) + "/blueprints")

require "fakeweb"
FakeWeb.allow_net_connect = false

Webrat.configure do |config|
  config.mode = :rack
  config.application_framework = :sinatra
  config.application_port = 4567
end

require "database_cleaner"
DatabaseCleaner[:mongo_mapper].strategy = :truncation
DatabaseCleaner.clean_with(:truncation)

RSpec.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)
  
  
   config.before(:each) do
     Sham.reset 
     DatabaseCleaner.start
   end

   config.after(:each) do
     DatabaseCleaner.clean
   end
   
  config.mock_with :rspec
end
