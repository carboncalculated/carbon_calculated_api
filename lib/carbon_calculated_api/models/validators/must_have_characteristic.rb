module Validators
  class MustHaveCharacteristic < ActiveModel::Validator
    def validate(record)
      valid = false
      if value = record.read_attribute_for_validation(options[:name])
        if object_id = BSON::ObjectId.from_string(value.to_s) rescue nil
          if generic_object = GenericObject.find(object_id)
            characteristics = generic_object.characteristics + generic_object.relatable_characteristics
        
             characteristics.detect do |characteristic|
              if characteristic["attribute"] == options[:characteristic_attribute]
                if value = options[:characteristic_value]
                  valid = characteristic["value"] == value
                else
                  valid = true
                end
              end
            end
          end
        end
      end
      message = "This Object does not have the desired characteristic: #{options[:characteristic_attribute]}"
      message << " with value: #{options[:characteristic_value]}" if options[:characteristic_value]
      record.errors[:base] << message unless valid
    end
    
  end
end
