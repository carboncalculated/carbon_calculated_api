class Equation
  include MongoMapper::EmbeddedDocument
  
  # == Keys
  key :equation_type, String, :default => "co2"
  key :formula, String
  key :units, String, :default => "kg/year"
  
  # == Validations
  validates_inclusion_of :equation_type, :within => %w(co2 n2o ch4 total_ghg)
  validates_presence_of :equation_type, :formula
  validates_true_for :equation_type, :logic => lambda { !equation_type.blank? }
  
end