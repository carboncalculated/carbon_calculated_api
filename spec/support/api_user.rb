require 'digest/sha1'
class ApiUser
  include MongoMapper::Document
  include MongoMapper::StateMachine
  
  # == Keys
  key :api_key, String
  key :email, String
  key :first_name, String
  key :last_name, String
  key :active_at, Time
  key :company_name, String
  timestamps!
  
  # == Validations
  validates_presence_of :api_key
  validates_presence_of :email
  
  # == hooks
  before_validation_on_create :generate_api_key!
  
  # == State Machine
  state_machine :initial => :pending do
    state :pending
    state :active

    event :activate do
      transitions :to => :active, :from => [:pending],  :on_transition => :set_active_at
    end
    
    event :deactivate do
      transitions :to => :pending, :from => [:active]
    end
  end

  def full_name
    %(#{ first_name } #{ last_name })
  end

  protected
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def generate_api_key!
    self.api_key =  secure_digest(Time.now, (1..10).map{ rand.to_s })
  end
  
  def set_active_at
    self.active_at = Time.now
    self.save!
  end
end