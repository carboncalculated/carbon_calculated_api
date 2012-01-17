module Validators
  class CharacteristicCondition < ActiveModel::Validator
    def validate(record)
      valid = false
      if value = record.read_attribute_for_validation(options[:name])
        if object_id = BSON::ObjectId.from_string(value.to_s) rescue nil
          if generic_object = GenericObject.find(object_id)
            characteristics = generic_object.characteristics + generic_object.relatable_characteristics
        
             characteristics.detect do |characteristic|
              if characteristic["attribute"] == options[:characteristic_attribute]
                condition = options[:condition]
                value = characteristic["value"]
                self.instance_eval do
                  @input_value = value.to_f #to_f as we only compare on float conditions
                  def input
                    @input_value
                  end
                  valid = !!self.instance_eval(condition)
                end
                
              end
            end
            
          end
        end
      end
      record.errors[:base] << "#{options[:name]} :: #{options[:characteristic_attribute]} #{options[:condition]} condition has not been meet" unless valid
    end
    
  end
end
