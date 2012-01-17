class AnswerSet
  include MongoMapper::Document
  include MongoMapper::StateMachine
    
  # == State Machine
  state_machine :initial => :pending do
    state :pending
    state :active

    event :activate do
      transitions :to => :active, :from => [:pending],  :on_transition => :set_active_at
    end
    
    event :deactivate do
      transitions :to => :pending, :from => [:active], :guard => :make_sure_at_least_one_live
    end
  end
  
  many :equations
  
  many :answer_selects, :class_name => "AnswerChoices::Select"
  many :answer_variables, :class_name => "AnswerChoices::Variable"
  many :answer_object_references, :class_name => "AnswerChoices::ObjectReference"
  many :answer_options, :class_name => "AnswerChoices::Option"
 
  protected  
  def set_active_at
    self.active_at = Time.now
    self.save!
  end
end