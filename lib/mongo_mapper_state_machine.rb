module MongoMapper
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include ::Transitions
      key :model_state, String
      before_validation :set_initial_state
      validates_presence_of :model_state
    end

    def model_state
      read_attribute(:model_state) || self.class.state_machine.initial_state.to_s
    end

    protected
    def write_state(state_machine, state)
      update_attributes! :model_state => state.to_s
    end

    def read_state(state_machine)
      self.model_state.to_sym
    end

    def set_initial_state
      model_state = self.class.state_machine.initial_state.to_s
    end
  end
end