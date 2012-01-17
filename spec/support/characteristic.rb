class Characteristic
  include MongoMapper::EmbeddedDocument

  TYPES = ["String", "Boolean", "Float", "Integer"]

  # Keys
  key :attribute, String
  key :value, String
  key :_type, String
  key :units, String
  key :value_type, String

  # Validations
  validates_inclusion_of :value_type, :within => TYPES
  validates_presence_of :value
  validates_presence_of :attribute
end