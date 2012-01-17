module AnswerChoices
  class Option < AnswerChoice
      
    # == Keys
    # key :options, Hash # <String>
    # key :default_option, String
    
    # @param [Symbol, #to_s]
    # @return [Object] value from the hash basically it can be
    # anything 
    def value(calculating_answer, option)
      options[option.to_s].to_f
    end

  end
end
