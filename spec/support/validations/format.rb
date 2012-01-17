module Validations
  class Format < Validation
    
    # == Keys
    key :name, String, :default => "validates_format_of"    
    
    OPTIONS = [:with]

  end
end