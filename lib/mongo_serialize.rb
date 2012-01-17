module MongoMapper
  module Serialize
    extend ActiveSupport::Concern
    
    included do
      def self.attributes_for_api; []; end
      def self.attributes_for_columns;[]; end
      def self.columns
        self.attributes_for_columns.map{|c| {:name => c}}
      end
    end
    
    module InstanceMethods
      def attributes_for_api_resource
        result = {self.api_name => {}}
        self.class.attributes_for_api.each do |key|
          result[self.api_name][key] = self.send(key)
        end
        result
      end
      
      def attributes_for_api_resources
        result = {}
        self.class.attributes_for_api.each do |key|
          result[key] = self.send(key)
        end
        result
      end
    
      def api_name
        self.class.name.demodulize.underscore
      end
      
      def to_json
        attributes_for_api_resource.to_json
      end
    end
  end
end
