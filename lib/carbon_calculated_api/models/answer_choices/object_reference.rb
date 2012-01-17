# SO ObjectReference wants an object of a certain 
# Type however there is no deemed type; so name is the 
# distinction here
module AnswerChoices
  class ObjectReference < AnswerChoice      
    # == Keys
    # key :object_name, String        
    # @param [String] object_id
    # @param [Symbol] attribute 


    # @return [Float] the value from the characteristic
    # only order hashes come back form characteristics therefore
    # cannot ask for method basically!
    def value(calculating_answer, object_id, formula_input_name, value_key, active_at)
      if generic_object = GenericObject.first(:id => object_id, :template_name => self["object_name"])
        if formula_input = generic_object.formula_input_by_active_at(formula_input_name.to_s, active_at)
          save_object_for_api(calculating_answer, generic_object, formula_input)
          formula_input["values"] && formula_input["values"][value_key.to_s].to_f
        end
      else
        raise ::Calculator::GenericObjectNotFound.new("Generic Object with ID #{object_id} Object Template #{self["object_name"]} does not exist")
      end
    end
    
    
    # @param [String] object_id
    # @param [Symbol] attribute 
    #
    # @return [String] the string value from the characteristic
    def characteristic_value(calculating_answer, object_id, attribute)
      if generic_object = GenericObject.first(:id => object_id, :template_name => self["object_name"])
        if characteristic = generic_object.characteristics.detect{|c|c["attribute"] == attribute.to_s}
          save_object_for_api(calculating_answer, generic_object)
          characteristic["value"]
        end
      else
        raise ::Calculator::GenericObjectNotFound.new("Generic Object with ID #{object_id} Object Template #{self["object_name"]} does not exist")
      end
    end
    
    private    
    def save_object_for_api(calculating_answer, object, formula_input = nil)
      object_references = calculating_answer.object_references
      object_ref = object_references[object.id.to_s] || object.attributes_for_api_resources
      if formula_input
        if object_ref["used_formula_inputs"]
          object_ref = object_ref["used_formula_inputs"].merge!({formula_input["name"] => formula_input})
        else
          object_ref = object_ref.merge!({"used_formula_inputs" => {formula_input["name"] => formula_input}})
        end
      end
      calculating_answer.object_references.merge!(object_ref["id"] => object_ref)
    end
         
  end
end
