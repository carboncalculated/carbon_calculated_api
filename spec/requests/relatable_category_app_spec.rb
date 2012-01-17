require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "RelatableCategoryApp" do
  def app
    @app = Rack::Builder.app do
      run CarbonCalculatedApi::RelatableCategoryApp
    end
  end
  
  describe "GET /relatable_categories/:id/related_categories (HTTP_ACCEPT json)", "Given there are relatable categories" do
    before(:each) do
      @user = ApiUser.make
      @user.activate!

      @template = ObjectTemplate.make(
        :name => "TV", 
        :relatable_characteristics => [{:attribute => "manufacture", :value_type => "String"}, {:attribute => "size", :value_type => "String"}, {:attribute => "epeat", :value_type => "String"}],
        :characteristics => [{:attribute => "label", :value_type => "String"}]
        )
      3.times do |i|
        @object_plan = GenericObject.plan(:object_template_id => @template.id)
        @object = GenericObject.new(@object_plan)
        @object.stub_characteristics_from_template!
        @object.relatable_characteristics[0].value = "Sony"
        @object.relatable_characteristics[1].value = "41"
        @object.relatable_characteristics[2].value = "silver"
        @object.characteristics.each{|c|c.value = "stub"}
        label = @object.characteristics.detect{|c| c.attribute == "label"}
        label.value = "stub#{i}"
        @object.save!
      end
    end
      
    describe "when asking for relatable categories for a TV", "with related_attribute 'manfacture'" do
      before(:each) do
        @relatable_category = RelatableCategory.first :name => "41", :related_object_name => "tv", :related_attribute => "size"
        @related_categories = @relatable_category.related_categories
      end
      it "should bring back the related_categories for that related category for size" do
        response = get("/relatable_categories/#{@relatable_category.id.to_s}/related_categories?api_key=#{@user.api_key}", {:related_attribute => "manufacture"}, { 'HTTP_ACCEPT' => 'application/json'})
        json = JSON.parse(response.body)["related_categories"]
        json.should == {RelatableCategory.first(:name => "sony", :related_object_name => "tv", :related_attribute => "manufacture").id.to_s => "sony"}
      end
    end
  end
  
  describe "GET /relatable_categories/related_objects (HTTP_ACCEPT json)", "Given there are relatable_categories" do
    before(:each) do
      @user = ApiUser.make
      @user.activate!
      
      @template = ObjectTemplate.make(
        :name => "TV", 
        :relatable_characteristics => [{:attribute => "manufacture", :value_type => "String"}, {:attribute => "size", :value_type => "String"}, {:attribute => "epeat", :value_type => "String"}],
        :characteristics => [{:attribute => "label", :value_type => "String"}]
      )
      3.times do |i|
        @object_plan = GenericObject.plan(:object_template_id => @template.id)
        @object = GenericObject.new(@object_plan)
        @object.stub_characteristics_from_template!
        @object.relatable_characteristics[0].value = "Sony"
        @object.relatable_characteristics[1].value = "41"
        @object.relatable_characteristics[2].value = "silver"
        @object.characteristics.each{|c|c.value = "stub"}
        label = @object.characteristics.detect{|c| c.attribute == "label"}
        label.value = "stub - one#{i}"
        @object.save!
      end
      
      2.times do |i|
        @object_plan = GenericObject.plan(:object_template_id => @template.id)
        @object = GenericObject.new(@object_plan)
        @object.stub_characteristics_from_template!
        @object.relatable_characteristics[0].value = "Sony"
        @object.relatable_characteristics[1].value = "101"
        @object.relatable_characteristics[2].value = "silver"
        @object.characteristics.each{|c|c.value = "stub"}
        label = @object.characteristics.detect{|c| c.attribute == "label"}
        label.value = "stub - two#{i}"
        @object.save!
      end
      
      1.times do |i|
        @object_plan = GenericObject.plan(:object_template_id => @template.id)
        @gold_object = GenericObject.new(@object_plan)
        @gold_object.stub_characteristics_from_template!
        @gold_object.relatable_characteristics[0].value = "Sony"
        @gold_object.relatable_characteristics[1].value = "101"
        @gold_object.relatable_characteristics[2].value = "gold"
        @gold_object.characteristics.each{|c|c.value = "stub"}
        label = @object.characteristics.detect{|c| c.attribute == "label"}
        label.value = "stub - three#{i}"
        @gold_object.save!
      end
      
      3.times do |i|
        @object_plan = GenericObject.plan(:object_template_id => @template.id)
        @object = GenericObject.new(@object_plan)
        @object.stub_characteristics_from_template!
        @object.relatable_characteristics[0].value = "Panasonic"
        @object.relatable_characteristics[1].value = "101"
        @object.relatable_characteristics[2].value = "silver"
        @object.characteristics.each{|c|c.value = "stub"}
        label = @object.characteristics.detect{|c| c.attribute == "label"}
        label.value = "stub - four#{i}"
        @object.save!
      end
      
      3.times do |i|
        @object_plan = GenericObject.plan(:object_template_id => @template.id)
        @object = GenericObject.new(@object_plan)
        @object.stub_characteristics_from_template!
        @object.relatable_characteristics[0].value = "Lg"
        @object.relatable_characteristics[1].value = "76"
        @object.relatable_characteristics[2].value = "gold"
        @object.characteristics.each{|c|c.value = "stub"}
        label = @object.characteristics.detect{|c| c.attribute == "label"}
        label.value = "stub - five#{i}"
        @object.save!
      end
    end

    describe "when asking for related_objects for just Sony Category from manufacture" do
      before(:each) do
        @relatable_category = RelatableCategory.first(:related_object_name => "tv", :related_attribute => "manufacture", :name => "sony")
        @related_objects = @relatable_category.related_objects
      end

      it "should bring back the related objects for the sony manufacture" do
        response = get("/relatable_categories/related_objects?api_key=#{@user.api_key}", {:template_name => "tv", :relatable_category_ids => [@relatable_category.id.to_s]}, { 'HTTP_ACCEPT' => 'application/json'})
        json = JSON.parse(response.body)["related_objects"]
        json.should == @related_objects
      end
    end

    describe "when asking for related_objects for just Tv Size 101" do
      before(:each) do
        @relatable_category = RelatableCategory.first(:related_object_name => "tv", :related_attribute => "size", :name => "101")
        @related_objects = @relatable_category.related_objects
      end

      it "should bring back the related objects for TV size 101" do
        response = get("/relatable_categories/related_objects?api_key=#{@user.api_key}", {:template_name => "tv", :relatable_category_ids => [@relatable_category.id.to_s]}, { 'HTTP_ACCEPT' => 'application/json'})
        json = JSON.parse(response.body)["related_objects"]
        json.should == @related_objects
      end
    end

    describe "when asking for related_objects for just Sony Category And Tv Size 101" do
      before(:each) do
        @relatable_category = RelatableCategory.first(:related_object_name => "tv", :related_attribute => "manufacture", :name => "sony")
        @relatable_category2 = RelatableCategory.first(:related_object_name => "tv",:related_attribute => "size", :name => "101")
        @related_objects = @relatable_category2.related_objects
      end

      it "should bring back the related objects which should be 2 as only 2 sony tv with size 101 exists" do
        response = get("/relatable_categories/related_objects?api_key=#{@user.api_key}", {:template_name => "tv", :relatable_category_ids => [@relatable_category.id.to_s, @relatable_category2.id.to_s]}, { 'HTTP_ACCEPT' => 'application/json'})
        json = JSON.parse(response.body)["related_objects"]
        json.size.should == 3
      end
    end
    
    
    describe "when asking for related_objects for just Sony Category And Tv Size 101 from manufacture and epeat gold" do
      before(:each) do
        @relatable_category = RelatableCategory.first(:related_attribute => "manufacture", :name => "sony")
        @relatable_category2 = RelatableCategory.first(:related_attribute => "size", :name => "101")
        @relatable_category3 = RelatableCategory.first(:related_attribute => "epeat", :name => "gold")
        @related_objects = @relatable_category3.related_objects["tv"]
      end

      it "should bring back the related objects which should be 1 as only 1 sony tv with size 101 exists" do
        response = get("/relatable_categories/related_objects?api_key=#{@user.api_key}", {:template_name => "tv", :relatable_category_ids => [@relatable_category.id.to_s, @relatable_category2.id.to_s, @relatable_category3.id.to_s]}, { 'HTTP_ACCEPT' => 'application/json'})
        json = JSON.parse(response.body)["related_objects"]
        json.should == {@gold_object.id.to_s => "stub"}
      end
    end

  end
end
