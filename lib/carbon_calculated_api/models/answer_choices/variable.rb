module AnswerChoices
  class Variable < AnswerChoice
      
    # == Keys
    # key :default_value, String, :default => 1
    # key :units, String
      
    # if its not given a value the default_value is returned
    # This is for equations that say have 1 person; etc
    # Return flight * 2 etc defaults to 1 by default; default
    def value(calculating_answer, parsed_value = nil)
      (parsed_value || default_value).to_f
    end

  end
end
