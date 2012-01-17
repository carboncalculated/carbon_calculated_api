require 'digest/sha1'
class ApiUser
  include MongoMapper::Document
  include MongoMapper::StateMachine
  
  # == Keys
  # key :api_key, String
  # key :email, String
  # key :first_name, String
  # key :last_name, String
  # key :active_at, Time
  # timestamps!
end