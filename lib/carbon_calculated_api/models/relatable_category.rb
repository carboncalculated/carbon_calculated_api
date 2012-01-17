class RelatableCategory
  include MongoMapper::Document
  include CarbonCalculatedApi::Model

  # key :name, String
  # key :related_attribute, String # transport_type
  # key :related_object_name, String # construction_transport
  # key :related_objects, Hash, :default => {} #{"dsfasdfasdf3453" => "sdafsdfads"}
  # key :related_categories, Hash, :default => {} # {:mode_of_transport => {:id => "32432", "name" => "Car"}
  
  # == Indexes
  ensure_index :name
  ensure_index :related_attribute
  ensure_index :related_object_name
  
  # @todo not sure if they should bring back ids or not at present
  def self.attributes_for_api
    %w(id name related_attribute related_object_name related_categories related_objects)
  end
  
  def self.related_objects_from_relatable_category_ids(template_name, related_category_ids)
    related_categories = RelatableCategory.find(related_category_ids)
    selected_related_object_ids = []
    related_objects = {}
    related_category_names = related_categories.map(&:name)
    
    
    all_related_objects = related_categories.inject({}) do |var, rc|
      var.merge!(rc.related_objects)
      var
    end
        
    related_categories.each do |rc|
      if selected_related_object_ids.empty?
        selected_related_object_ids = rc.related_objects.keys
      else
        selected_related_object_ids =  selected_related_object_ids & rc.related_objects.keys
      end
      if selected_related_object_ids.empty?
        related_objects = {}
        break
      else
        related_objects = selected_related_object_ids.inject({}){|var, id| var.merge!({id=>all_related_objects[id]}); var}
      end
    end
    clean_identifier_names!(related_category_names, related_objects)
  end
  
  def self.relatable_categories_from_intersected(relatable_category, related_attribute, related_category_ids = [])
    relatable_categories = RelatableCategory.find((related_category_ids << relatable_category.id.to_s))
    selected_related_category_ids = []
    related_categories = {}
     
    all_related_categories = relatable_categories.inject({}) do |var, rc|
      relatables = rc.related_categories[related_attribute]
      if !relatables.nil?
        var.merge!(rc.related_categories[related_attribute])
      end
      var
    end
      
    relatable_categories.each do |rc|
      if selected_related_category_ids.empty?
        selected_related_category_ids = (rc.related_categories[related_attribute].try(:keys) || [])
      else
        selected_related_category_ids =  selected_related_category_ids & (rc.related_categories[related_attribute].try(:keys) || [])
      end
      if selected_related_category_ids.empty?
        related_categories = {}
        break
      else
        related_categories = selected_related_category_ids.inject({}){|var, id| var.merge!({id=>all_related_categories[id]}); var}
      end
    end
    related_categories
  end
  
  private
  # @param [Array<String>] names
  # @param [Hash] related_objects
  # @return [Hash] related_objects
  def self.clean_identifier_names!(names, related_objects = {})
    related_objects.each_pair do |key, value|
      join_names = related_objects[key].split("-").map(&:squish!)
      names.each do |name|
        join_names = join_names.select do |j_name|
          regexp = Regexp.compile("^#{name}$", true)
          result = j_name =~ regexp
          result.nil?
        end
        sub_value = join_names.join(" - ")
        related_objects[key] = sub_value
      end
    end
  end
  
end
