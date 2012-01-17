class MainSource
  include MongoMapper::Document
  include MongoMapperExt::Tags
  
  # == Keys
  key :name, String
  key :description, String
  key :external_url, String
  key :wave_id, String
end