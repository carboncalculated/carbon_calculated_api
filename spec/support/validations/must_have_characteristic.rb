module Validations
  class MustHaveCharacteristic < Validation
    
    # == Keys
    key :name, String, :default => "validates_with"
    key :has_validator, Boolean, :default => true
    key :validator_class, String, :default =>  "Validators::MustHaveCharacteristic"
    
    OPTIONS = [:characteristic_attribute, :characteristic_value]
    
    # == Validation
    validates_true_for :options, :logic => Proc.new {!options["name"].blank? && !options["characteristic_attribute"].blank?}, :message => "Must have characteristic_attribute and name the options"
    
  end
end