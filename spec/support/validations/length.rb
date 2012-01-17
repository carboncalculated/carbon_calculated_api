module Validations
  class Length < Validation
    
    # == Keys
    key :name, String, :default => "validates_length_of"
    
    OPTIONS = [:within, :maximum, :minimum, :is]
    
  end
end