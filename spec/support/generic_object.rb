class GenericObject
  include MongoMapper::Document
  
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
  
  # == Assocations
  many :characteristics
  many :relatable_characteristics, :class_name => "Characteristics::Relatable"
  many :formula_inputs
  belongs_to :object_template
    
  # == Validations
  validates_presence_of :template_name
  validates_associated :characteristics
  validates_associated :relatable_characteristics
  validates_uniqueness_of :identifier, :scope => :template_name
  
  # == Hooks
  before_validation_on_create :add_template_name
  before_validation_on_create :downcase_template_name
  before_validation :add_identifier
  before_save :clean_related_categories
  before_save :add_relatable_characteristic_values
  after_save :update_related_categories
  after_destroy :destroy_related_categories
  
  # == Filters
  include MongoMapperExt::Filter
  filterable_keys :identifier, :relatable_characteristic_values
    
  def full_characteristics
    @full_characteristics ||= characteristics + relatable_characteristics
  end
    
  # Tempalate defined characteristics so we need to use them!
  def stub_characteristics_from_template!
    if self.object_template
      object_template.characteristics && object_template.characteristics.each do |attrs|
        self.characteristics << Characteristic.new(attrs)
      end
      object_template.relatable_characteristics && object_template.relatable_characteristics.each do |attrs|
        self.relatable_characteristics << Characteristics::Relatable.new(attrs)
      end
      object_template.formula_inputs && object_template.formula_inputs.each do |attrs|
        self.formula_inputs << FormulaInput.new(attrs)
      end
    end
  end
  
  # Build from passed in params hash
  def build_embedded_documents(options)
    options ||= {}
    characteristic_params = options.delete(:characteristics) || []
    relatable_characteristic_params = options.delete(:relatable_characteristics) || []
    formula_input_params = options.delete(:formula_inputs) || []
    
    characteristic_params.each do |object_id, attributes|
      self.characteristics.build({ :_id => object_id }.merge(attributes))
    end
    relatable_characteristic_params.each do |object_id, attributes|
      self.relatable_characteristics.build({ :_id => object_id }.merge(attributes))
    end
    formula_input_params.each do |object_id, attributes|
      self.formula_inputs.build({ :_id => object_id }.merge(attributes))
    end
  end
  
  def update_embedded_documents(options)
    options ||= {}
    characteristic_params = options.delete(:characteristics) || []
    relatable_characteristic_params = options.delete(:relatable_characteristics) || []
    formula_input_params = options.delete(:formula_inputs) || []
    
    characteristic_params.each do |object_id, attributes|
      self.characteristics.find(object_id).update_attributes(attributes)
    end
    relatable_characteristic_params.each do |object_id, attributes|
      self.relatable_characteristics.find(object_id).update_attributes(attributes)
    end
    formula_input_params.each do |object_id, attributes|
      self.formula_inputs.find(object_id).update_attributes(attributes)
    end
  end
  
  protected
  def add_relatable_characteristic_values
    self.relatable_characteristic_values = self.relatable_characteristics.map do |rc|
      rc["value"]
    end
  end
  
  def add_identifier
    ident = []
    identifiers = object_template.object_characteristic_identifiers.each do |char_ident|
      full_characteristics.detect do |char|
        ident << char.value if char.attribute == char_ident 
      end
    end
    self.identifier = ident.join(" - ")
  end
  
  def add_template_name
    self.template_name = self.template_name || self.object_template.name
  end
  
  # == for updates we need to destroy any relatables that 
  # are happening basically
  def destroy_relatables
   relatable_characteristics.each do |rc|
      if related_category = ::RelatableCategory.first(:name => rc.value.downcase, :related_attribute => rc.attribute.downcase, :related_object_name => self.template_name)
        related_category.related_objects.merge!({self.id.to_s => self.identifier})
        related_category.save!
        related_categories << related_category
      end
    end
  end
  
  # Related Categories are some cool shit!
  # they enable categorization on the fly
  def update_related_categories
    related_categories = []
    relatable_characteristics.each do |rc|
      related_category = ::RelatableCategory.first_or_create(:name => rc.value.downcase, :related_attribute => rc.attribute.downcase, :related_object_name => self.template_name)
      related_category.related_objects.merge!({self.id.to_s => self.identifier})
      related_category.save!
      related_categories << related_category
    end
    update_related_category_categories(related_categories)
  end
  
  # yes bad name!!
  def update_related_category_categories(related_categories)
    related_categories.each do |rc, index|
      applying_categories = related_categories.reject{|ac| rc.name == ac.name}
      applying_categories.each do |apply_related|
        if rc.related_categories[apply_related.related_attribute]
          rc.related_categories[apply_related.related_attribute].merge!({apply_related.id.to_s => apply_related.name})
        else
          rc.related_categories[apply_related.related_attribute] = {apply_related.id.to_s => apply_related.name}
        end
        rc.save!
      end
    end
  end

  def destroy_related_categories
    relatable_characteristics.each do |rc|
      if related_category = ::RelatableCategory.first(:name => rc.value.downcase, :related_attribute => rc.attribute.downcase, :related_object_name => self.template_name)
        related_category.related_objects.delete(self.id.to_s)
        related_category.save
      end
    end
  end
  
  def clean_related_categories
    self.relatable_characteristic_values.each do |old_value|
      if related_category = ::RelatableCategory.first(:name => old_value, :related_object_name => self.template_name)
        related_category.related_objects.delete(self.id.to_s)
        related_category.save
      end
    end
    self.relatable_characteristic_values = []
  end
  
  # make sure we have a downcase template_name; makes
  # for a more universal search
  def downcase_template_name
    self.template_name = template_name.downcase if template_name
  end
end