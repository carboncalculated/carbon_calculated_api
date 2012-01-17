require 'sinatra/base'
require 'rack/contrib/accept_format'

require "active_support/hash_with_indifferent_access"
require "active_support/core_ext/module"
require "active_support/core_ext/hash"
require "active_support/core_ext/class"
require "active_support/buffered_logger"
require 'active_support/core_ext/float'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/attr_accessor_with_default'
require "active_model"
require "mongo_mapper"
require "mongomapper_ext"

lib_dir = File.expand_path(File.join(File.dirname(__FILE__)))

require File.join(lib_dir, 'mongo_mapper_state_machine')
require File.join(lib_dir, 'mongo_serialize')

require File.join(lib_dir, 'carbon_calculated_api', 'models', 'model')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'calculator')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'object_template')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'generic_object')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'formula_input')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'answer_choice')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'relatable_category')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'computation')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'answer_choices', 'object_reference')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'answer_choices', 'option')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'answer_choices', 'variable')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'answer_choices', 'select')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'source')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'answer_set')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'validation')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'answer')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'global_computation')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'global_constant')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'api_user')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'validators', 'must_have_characteristic')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'validators', 'must_not_have_characteristic')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'validators', 'condition')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'validators', 'one_of_many_with_condition')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'validators', 'must_have_formula_input_name')
require File.join(lib_dir, 'carbon_calculated_api', 'models', 'validators', 'characteristic_condition')


require File.join(lib_dir, 'carbon_calculated_api', 'api', 'version_mapper')
require File.join(lib_dir, 'carbon_calculated_api', 'api')
require File.join(lib_dir, 'carbon_calculated_api', 'api', "generic_object_app")
require File.join(lib_dir, 'carbon_calculated_api', 'api', "object_template_app")
require File.join(lib_dir, 'carbon_calculated_api', 'api', "answer_app")
require File.join(lib_dir, 'carbon_calculated_api', 'api', "relatable_category_app")

module CarbonCalculatedApi

  def self.[](key)
    unless @config
      @config = self.config[ENV["RACK_ENV"]].symbolize_keys
    end
    @config[key]
  end
  
  def self.config
    YAML.load(File.read(File.join(File.dirname(__FILE__), "carbon_calculated_api", "config", "carbon_calculated.yml")))
  end
  
  def self.[]=(key, value)
    @config[key.to_sym] = value
  end
end
