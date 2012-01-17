module Validations
  class Condition < Validation
    # == Keys
    key :name, String, :default => "validates_with"
    key :has_validator, Boolean, :default => true
    key :validator_class, String, :default =>  "Validators::Condition"
    OPTIONS = [:name, :condition]
    
    # == Validation
    validates_true_for :options, :logic => Proc.new {!options["name"].blank? && !options["condition"].blank?}, :message => "Must have condition and name in the options"
  end
end