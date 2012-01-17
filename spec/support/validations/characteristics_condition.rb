module Validations
  class CharacteristicCondition < Validation
    
    # == Keys
    key :name, String, :default => "validates_with"
    key :has_validator, Boolean, :default => true
    key :validator_class, String, :default =>  "Validators::CharacteristicCondition"
    
    OPTIONS = [:characteristic_attribute, :condition]
    
    # == Validation
    validates_true_for :options, :logic => Proc.new {!options["name"].blank? && !options["characteristic_attribute"].blank? && !options["condition"].blank?}, :message => "Must have characteristic_attribute and name the options"
    
  end
end