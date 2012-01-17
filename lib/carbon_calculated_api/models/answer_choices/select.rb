module AnswerChoices
  class Select < AnswerChoice
          
    # @param [Symbol, #to_s]
    # @return [String] parsed_value just allows calls to be made
    # for values that are not just floats use for futher 
    # global computes
    def value(calculating_answer, parsed_value = nil)
      (parsed_value || default_value)
    end

  end
end
