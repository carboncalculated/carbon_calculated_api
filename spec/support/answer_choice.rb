# Is choice not just an FVariable???
class AnswerChoice
  include MongoMapper::Document

  # == Keys
  key :_type, String
  key :name, String # Once needs to match to this; for validatiaon
  key :external_name, String # for use with external providers to match their keys
  key :answer_set_id, ObjectId
  key :units, String
  timestamps!
  
  # == Indexes
  ensure_index :name
  
  # == Associations
  many :validations, :as => :validatable
  belongs_to :answer_set
  
  # == Validations
  validates_presence_of :name
  validates_presence_of :answer_set_id
end