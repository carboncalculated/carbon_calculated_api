module Validations
  class OneOfManyWithCondition < Validation
    
    # == Keys
    key :name, String, :default => "validates_with"
    key :has_validator, Boolean, :default => true
    key :validator_class, String, :default =>  "Validators::OneOfManyWithCondition"
    
    OPTIONS = [:names, :condition]
    
  end
end