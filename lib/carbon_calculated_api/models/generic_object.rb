class GenericObject
  include MongoMapper::Document
  include CarbonCalculatedApi::Model
  include MongoMapperExt::Filter
  
  # == Keys
  key :object_template_id, ObjectId
  key :template_name, String
  key :identifier, String
  key :relatable_characteristic_values, Array
  key :external_vendor_ids, Array
  timestamps!
  
  # == Indexing
  ensure_index :template_name
  ensure_index :external_vendor_ids
  ensure_index "characteristics.attribute"
  ensure_index "relatable_characteristics.attribute"
  ensure_index "characteristics.value"
  ensure_index "relatable_characteristics.value"
  ensure_index "formula_inputs.name"
  ensure_index "formula_inputs.input_units"
    
  filterable_keys :identifier, :relatable_characteristic_values
  
  # @todo pagination on this mother as well
  def self.filter_with_template_name(template_name, search, per_page, page, related_category_values = []) 
    related_category_values.reject!{|rl| rl.blank?}
    if related_category_values.empty?
      self.filter(search, :template_name => template_name, :per_page => per_page, :page => page)
    else
      results = self.filter(search, :template_name => template_name, :relatable_characteristic_values.all => related_category_values, :per_page => per_page, :page => page)
      clean_identifier_names!(related_category_values, results)
      results
    end
  end

  def self.attributes_for_api
    %w(id template_name characteristics formula_inputs identifier)
  end

  def characteristics
    (super + relatable_characteristics).map do |c_hash|
      c_hash.delete("_type")
      c_hash.merge!("id" => c_hash.delete("_id"))
    end
  end
  
  def formula_inputs
    old_formula_inputs = super rescue []
    (old_formula_inputs ||[]).map do |f_hash|
      f_hash.merge!("id" => f_hash.delete("_id"))
    end
  end
  
  def to_json
    attributes_for_api_resource.to_json
  end
  
  def formula_input_by_active_at(formula_name, active_at = Time.now)
    inputs = self.formula_inputs.select{|f| f["name"] == formula_name && f["model_state"] == "active"}
    sorted_inputs = inputs.sort_by{|f| f["active_at"]}.reverse
    sorted_inputs.detect{|si| si["active_at"] < active_at} || sorted_inputs.first
  end
  
  protected 
  def self.clean_identifier_names!(related_object_names, generic_objects = [])
    generic_objects.each do |g_object|
      join_names = g_object.identifier.split("-").map(&:squish!)
      related_object_names.each do |name|
        join_names = join_names.select do |j_name|
          regexp = Regexp.compile("^#{name}$", true)
          result = j_name =~ regexp
          result.nil?
        end
          sub_value = join_names.join(" - ")
          g_object.identifier = sub_value
      end
    end
  end
  
end
