begin
  # Try to require the preresolved locked set of gems.
  require ::File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require(:default)

require ::File.expand_path(::File.join(::File.dirname(__FILE__), "lib", "carbon_calculated_api"))
mongo_config = CarbonCalculatedApi.config.with_indifferent_access

# == todo what logger then that is the 3rd option basically
MongoMapper.setup(mongo_config, ENV["RACK_ENV"])

# The Api application
run CarbonCalculatedApi::API.app
