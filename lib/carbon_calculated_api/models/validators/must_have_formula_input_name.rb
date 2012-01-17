module Validators
  class MustHaveFormulaInputName < ActiveModel::Validator
    
    # This validates any object_reference where in an equation we 
    # use its formula inputs vai another answer choice; 
    # ie formala_input(:transport, value(:units), :co2)
    # Therefore we want to make sure the value given for units is actually
    # a formula inputs for that object
    def validate(record)
      valid = false
      if object_reference_value = record.read_attribute_for_validation(options[:object_reference_name])
        if object_id = BSON::ObjectId.from_string(object_reference_value.to_s) rescue nil
          if generic_object = GenericObject.find(object_id)
            if generic_object.formula_inputs.any? do |formula_input|
                formula_input["name"] == record.read_attribute_for_validation(options[:name])
              end
              valid = true
            end
          end
        end
      end
      record.errors[:base] << "Object #{options[:object_reference_name]} does not have formula input with name #{record.read_attribute_for_validation(options[:name])}" unless valid
    end
    
  end
end