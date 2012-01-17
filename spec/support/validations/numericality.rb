module Validations
  class Numericality < Validation
    
    # == Keys
    key :name, String, :default => "validates_numericality_of"
    
    OPTIONS = []
    
  end
end