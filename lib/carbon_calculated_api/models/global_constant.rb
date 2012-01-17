class GlobalConstant  
  include MongoMapper::Document
  include CarbonCalculatedApi::Model
  
    # Keys
    key :name, String #needs to be unique
    key :value, Float
    key :units, String
    
end