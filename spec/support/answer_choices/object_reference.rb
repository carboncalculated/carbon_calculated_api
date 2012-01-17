# SO ObjectReference wants an object of a certain 
# Type however there is no deemed type; so name is the 
# distinction here
module AnswerChoices
  class ObjectReference < AnswerChoice
        
    # == Keys
    key :object_name, String
    
  end
end