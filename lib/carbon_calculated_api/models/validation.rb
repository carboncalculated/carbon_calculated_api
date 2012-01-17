class Validation
  include MongoMapper::Document
  include CarbonCalculatedApi::Model


  # == keys
  # key :options, Hash
  # key :message, String
  # key :_type, String
  # key :has_validator, String
  # key :answer_field_name, String
  # key :validatable_type, String
  # key :validatable_id, ObjectId

  # == Associations
  # belongs_to :validatable, :polymorphic => true

end
