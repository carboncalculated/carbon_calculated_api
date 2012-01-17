class Calculator
  include MongoMapper::Document
  include CarbonCalculatedApi::Model

  # == Defined Calculator Errors
  class Calculator::Error < StandardError; end
  class GenericObjectNotFound < Calculator::Error; end
  class NotFound < Calculator::Error; end
  class CalculationError < Calculator::Error; end
  class ExternalProviderError < Calculator::Error; end
  class NoCalculationExistsError < Calculator::Error; end

  # == Keys
  key :name, String, :unique => true, :required => true
  key :description, String
  key :tags, Array

  # == Associations
  many :computations

end
