class RelatableCategory
  include MongoMapper::Document

  key :name, String
  key :related_attribute, String # transport_type
  key :related_object_name, String # construction_transport
  key :related_objects, Hash, :default => {} #{"dsfasdfasdf3453" => "sdafsdfads"}
  key :related_categories, Hash, :default => {} # {:mode_of_transport => {:id => "32432", "name" => "Car"}
  timestamps!
  
  # == Indexes
  ensure_index :name
  ensure_index :related_attribute
  ensure_index :related_object_name
end