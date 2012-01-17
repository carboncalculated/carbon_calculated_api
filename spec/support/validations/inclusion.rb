module Validations
  class Inclusion < Validation
    
    # == Keys
    key :name, String, :default => "validates_inclusion_of"
    
    OPTIONS = [:in]
      
  end
end