module Validations
  class MustHaveFormulaInputName < Validation
    
    # == Keys
    key :name, String, :default => "validates_with"
    key :has_validator, Boolean, :default => true
    key :validator_class, String, :default =>  "Validators::MustHaveFormulaInputName"
    
    OPTIONS = [:object_reference_name]
    
    # == Validation
    validates_true_for :options, :logic => Proc.new {!options["name"].blank? && !options["object_reference_name"].blank?}, :message => "Must have object_reference_name and name in the options"
  
  end
end