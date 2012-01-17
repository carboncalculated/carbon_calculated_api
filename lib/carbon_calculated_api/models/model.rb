module CarbonCalculatedApi
  module Model
    extend ActiveSupport::Concern
    
    included do
      include MongoMapper::Serialize
      def self.ensure_index(*options)
        # this app should not set indexes
        # however plugins may want to like 
        # filtering for instance;
      end
    end
    
  end
end
