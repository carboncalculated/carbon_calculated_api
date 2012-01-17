class Computation
  include MongoMapper::Document
  include MongoMapper::StateMachine
  include MongoMapperExt::Tags
  
  # == Keys
  key :name, String
  key :calculator_id, ObjectId
  key :description, String
  key :active_at, Time
  key :position, Integer, :default => 1
  timestamps!
  
  # == Validations
  validates_presence_of :name
  validates_presence_of :calculator_id
  
  # == Indexes
  ensure_index :names
  
  # == Filters
  include MongoMapperExt::Filter
  filterable_keys :name, :tags
  
  # == State Machine
  state_machine :initial => :pending do
    state :pending
    state :active

    event :activate do
      transitions :to => :active, :from => [:pending], :on_transition => :set_active_at
    end
     
    event :deactivate do
      transitions :to => :pending, :from => [:active]
    end
  end
   
  
  # == Associations
  belongs_to :calculator
  many :answer_sets, :dependent => :destroy
  many :active_answer_sets, :class_name => "AnswerSet", :conditions => {:model_state => "active"}, :order => :active_at.asc
    
  protected
  def set_active_at
    self.active_at = Time.now
    self.save!
  end
end
