class Validation
  include MongoMapper::Document

  VALIDATION_TYPES = ["Validation", "Validations::Condition", "Validations::Format", "Validations::Inclusion", "Validations::Length", "Validations::MustHaveCharacteristic", "Validations::MustNotHaveCharacteristic", "Validations::Numericality", "Validations::Presence", "Validations::OneOfManyWithCondition", "Validations::MustHaveFormulaInputName"]

  # == keys
  key :options, Hash
  key :message, String
  key :_type, String
  key :has_validator, Boolean, :default => false
  key :answer_field_name, String
  key :validatable_type, String
  key :validatable_id, ObjectId
  
  # == Validations
  validates_presence_of :answer_field_name, :if => Proc.new{ validatable_type != "AnswerSet"}
  validates_presence_of :validatable_type
  validates_presence_of :validatable_id

  # == Associations
  belongs_to :validatable, :polymorphic => true
  
  # == Hooks
  before_validation_on_create :add_answer_field_name
  
  protected
  def add_answer_field_name
    if validatable && validatable.respond_to?(:name)
      self.answer_field_name = validatable.name
    end
  end
end
