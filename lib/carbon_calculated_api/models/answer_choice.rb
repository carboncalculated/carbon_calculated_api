class AnswerChoice
  include MongoMapper::Document
  include CarbonCalculatedApi::Model
  
  # == Associations
  many :validations, :as => :validatable
  belongs_to :answer_set
  
  # == Indexes
  ensure_index :name
   
end
