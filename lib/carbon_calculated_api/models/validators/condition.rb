module Validators
  class Condition < ActiveModel::Validator
    
    # @example
    #   value > 0 && value < 10
    def validate(record)
      valid = false
      if value = record.read_attribute_for_validation(options[:name])
        if condition = options[:condition]
          self.instance_eval do
            @input_value = value
            def input
              @input_value
            end
            valid = !!self.instance_eval(condition)
          end
        end
      end
      record.errors[:base] << "#{options[:name]} #{options[:condition]} condition has not been meet" unless valid
    end
          
  end
end