require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "GenericObjectApp" do
  def app
    @app = Rack::Builder.app do
      run CarbonCalculatedApi::GenericObjectApp
    end
  end
  
  describe "GET /generic_objects (HTTP_ACCEPT json) Given there are 10 generic_objects" do
    before(:each) do
      @user = ApiUser.make
      @user.activate!
      
      @template = ObjectTemplate.create!(:name => "tv", 
        :relatable_characteristics => [{:attribute => "manufacture", :value_type => "String"}],
        :characteristics => [{:attribute => "label", :value_type => "String"}]
      )
      
      10.times do |index|
        @object_plan = GenericObject.plan(:object_template_id => @template.id)
        @object = GenericObject.new(@object_plan)
        @object.stub_characteristics_from_template!
        @object.relatable_characteristics[0].value = "sony"
        @object.characteristics.each{|c|c.value = "stub"}
        label = @object.characteristics.detect{|c| c.attribute == "label"}
        label.value = "stub#{index}"
        @object.save!  
      end
    end
    
    it "should return a list of 10 generic objects" do
      response = get("/generic_objects?api_key=#{@user.api_key}", {}, { 'HTTP_ACCEPT' => 'application/json'})
      json = JSON.parse(response.body)["generic_objects"]
      json.should have(10).entries
    end
  end
  
  
  describe "GET /generic_objects/:id (HTTP_ACCEPT json) Given there exists an object with that id" do
    before(:each) do
      @user = ApiUser.make
      @user.activate!
      
      @template = ObjectTemplate.make(:name => "TV", :relatable_characteristics => [{:attribute => "manufacture", :value_type => "String"}])
      @object_plan = GenericObject.plan(:object_template_id => @template.id)
      @object = GenericObject.new(@object_plan)
      @object.stub_characteristics_from_template!
      @object.relatable_characteristics[0].value = "sony"
      @object.characteristics.each{|c|c.value = "stub"}
      @object.save! 
    end
    
    it "should return the generic object" do
      response = get("/generic_objects/#{@object.id}?api_key=#{@user.api_key}", { }, { 'HTTP_ACCEPT' => 'application/json'})
      json = JSON.parse(response.body)["generic_object"]
      json.should_not be_empty
      json["template_name"].should == "tv"
    end
  end
  
  
  describe "GET /generic_objects/:id (HTTP_ACCEPT json) Given object exists with some formul_inputs" do
    before(:each) do
      @user = ApiUser.make
      @user.activate!
      
      @template = ObjectTemplate.make(:name => "TV", 
        :relatable_characteristics => [
          {:attribute => "manufacture", :value_type => "String"}
        ],
        :formula_inputs => [
          {:name => "kilogram", :model_state => "active", :active_at => Time.now, :input_units => "kg/year", :label_input_units => "Kilogram units per yeah", :values => {"kilo" => 12}}
        ]
      )
      @object_plan = GenericObject.plan(:object_template_id => @template.id)
      @object = GenericObject.new(@object_plan)
      @object.stub_characteristics_from_template!
      @object.relatable_characteristics[0].value = "sony"
      @object.characteristics.each{|c|c.value = "stub"}
      @object.save!
    end
    
    it "should return the generic object with the input formulas" do
      response = get("/generic_objects/#{@object.id}?api_key=#{@user.api_key}", { }, { 'HTTP_ACCEPT' => 'application/json'})
      json = JSON.parse(response.body)["generic_object"]
      json.should_not be_empty
      json["template_name"].should == "tv"
    end
  end
  
  
  describe "GET /generic_objects/:id/formula_inputs (HTTP_ACCEPT json) Given object exists with some formula_inputs" do
    before(:each) do
      @user = ApiUser.make
      @user.activate!
      
      @template = ObjectTemplate.make(:name => "TV", 
        :relatable_characteristics => [
          {:attribute => "manufacture", :value_type => "String"}
        ],
        :formula_inputs => [
          {:name => "kilogram", :model_state => "active", :active_at => Time.now, :input_units => "kg/year", :label_input_units => "Kilogram units per yeah", :values => {"kilo" => 12}}
        ]
      )
      @object_plan = GenericObject.plan(:object_template_id => @template.id)
      @object = GenericObject.new(@object_plan)
      @object.stub_characteristics_from_template!
      @object.relatable_characteristics[0].value = "sony"
      @object.characteristics.each{|c|c.value = "stub"}
      @object.save!
    end
    
    it "should return the generic object with the input formulas" do
      response = get("/generic_objects/#{@object.id}/formula_inputs?api_key=#{@user.api_key}", { }, { 'HTTP_ACCEPT' => 'application/json'})
      json = JSON.parse(response.body)
      json.should_not be_empty
    end
  end
end
