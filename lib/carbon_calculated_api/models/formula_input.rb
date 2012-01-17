class FormulaInput
  include MongoMapper::EmbeddedDocument
  include CarbonCalculatedApi::Model
  include MongoMapper::StateMachine
  
  def self.attributes_for_api
    %w(id name values input_units label_input_units)
  end
  
end