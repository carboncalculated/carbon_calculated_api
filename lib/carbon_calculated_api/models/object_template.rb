class ObjectTemplate
  include MongoMapper::Document
  include CarbonCalculatedApi::Model
  
  # == Keys
  key :name, String
  key :characteristics, Set # Set<Hash>
  key :relatable_characteristics, Set # Set<Hash> 
  key :formula_inputs, Set 
  key :object_characteristic_identifiers, Set, :default => Set.new(["label"])
  timestamps!

  def self.attributes_for_api
    %w(id name characteristics formula_inputs)
  end

  def characteristics
    (super + relatable_characteristics)
  end
  
  def to_json
    attributes_for_api_resource.to_json
  end
  
  # == Associations
  many :generic_objects

  def relatable_categories_by_related_attribute(related_attribute, per_page, page)
    RelatableCategory.paginate(:per_page => per_page, :page => page, :related_attribute => related_attribute, :related_object_name => self.name)
  end

  def relatable_categories(per_page, page)
    RelatableCategory.paginate(:per_page => per_page, :page => page, :related_object_name => name)
  end
end
