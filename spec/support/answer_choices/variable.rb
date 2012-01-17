# SO ObjectReference wants an object of a certain 
# Type however there is no deemed type; so name is the 
# distinction here
module AnswerChoices
  class Variable < AnswerChoice
        
    # == Keys
    key :default_value, String
  end
end