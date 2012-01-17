class Source
  include CarbonCalculatedApi::Model
  include MongoMapper::EmbeddedDocument
  
  # == Keys
  key :name, String
  key :description, String
  key :main_source_ids, Array
  key :external_url, String
  key :wave_id, String
  
  def self.attributes_for_api
    %w(id description main_source_ids external_url wave_id)
  end
end