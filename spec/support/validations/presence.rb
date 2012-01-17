module Validations
  class Presence < Validation
    
    # == Keys
    key :name, String, :default => "validates_presence_of"

    OPTIONS = []
    
  end
end