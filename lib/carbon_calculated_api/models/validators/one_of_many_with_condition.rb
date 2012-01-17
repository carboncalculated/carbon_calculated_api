module Validators
  class OneOfManyWithCondition < ActiveModel::Validator
    
    # @example
    #   value > 0 && value < 10
    def validate(record)
      valid = false
      valid = options[:names].detect do |name|
        if value = record.read_attribute_for_validation(name)
          if condition = options[:condition]
            self.instance_eval do
              @input_value = value
              def input
                @input_value.to_f
              end
              !!self.instance_eval(condition)
            end
          end
        end
      end
      record.errors[:base] << "Conditions have not been meet" unless valid
    end
    
  end
end