require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ObjectTempateApp" do
  def app
    @app = Rack::Builder.app do
      run CarbonCalculatedApi::ObjectTemplateApp
    end
  end
  describe "GET /object_tempate/:name/generic_objects (HTTP_ACCEPT json)", "Given there exists an object_template with some objects" do
     before(:each) do
       @user = ApiUser.make
       @user.activate!
       @template = ObjectTemplate.make(
        :name => "tv", 
        :relatable_characteristics => [{:attribute => "manufacture", :value_type => "String"}],
        :characteristics => [{:attribute => "label", :value_type => "String"}]
        )
       10.times do |i|
         @object_plan = GenericObject.plan(:object_template_id => @template.id)
         @object = GenericObject.new(@object_plan)
         @object.stub_characteristics_from_template!
         @object.relatable_characteristics[0].value = "sony#{i}"
         @object.characteristics.each{|c|c.value = "stub#{i}"}
         label = @object.characteristics.detect{|c| c.attribute == "label"}
         label.value = "stub#{i}"
         @object.save!
         
        end
       @template2 = ObjectTemplate.make(:name => "AIRPORT", 
        :relatable_characteristics => [{:attribute => "airport", :value_type => "String"}],
        :characteristics => [{:attribute => "label", :value_type => "String"}]
        )
        5.times do |i|
           @object_plan = GenericObject.plan(:object_template_id => @template2.id)
           @object = GenericObject.new(@object_plan)
           @object.stub_characteristics_from_template!
           @object.relatable_characteristics[0].value = "sony"
           @object.characteristics.each{|c|c.value = "stub"}
           label = @object.characteristics.detect{|c| c.attribute == "label"}
           label.value = "stub#{i}"
           @object.save!
        end
     end

     it "should return 10 entries for object_template 'TV'" do
       response = get("/object_templates/Tv/generic_objects?api_key=#{@user.api_key}", { }, { 'HTTP_ACCEPT' => 'application/json'})
       json = JSON.parse(response.body)["object_template"]       
       json["generic_objects"].should have(10).entries
     end
     
     it "should return 5 entries for object_template 'AIRPORT'" do
       get("/object_templates/#{@template2.name}/generic_objects?api_key=#{@user.api_key}", { }, { 'HTTP_ACCEPT' => 'application/json'})
     end
   end
   
   describe "GET /object_templates/:name/relatable_categories (HTTP_ACCEPT json)", "Given there exists an object_template with relatable_charateries" do
     before(:each) do
       @user = ApiUser.make
       @user.activate!
       
       @template = ObjectTemplate.make(
        :name => "tv", 
        :relatable_characteristics => [{:attribute => "manufacture", :value_type => "String"}],
        :characteristics => [{:attribute => "label", :value_type => "String"}]
        )
       5.times do |i|
         @object = GenericObject.new(:object_template => @template)
         @object.stub_characteristics_from_template!
         @object.relatable_characteristics[0].value = "sony#{i}"
         @object.characteristics.each{|c|c.value = "stub#{i}"}
         label = @object.characteristics.detect{|c| c.attribute == "label"}
         label.value = "stub#{i}"
         @object.save!
       end
     end
      
    it "should return 5 entries for object_template 'TV'" do
      response = get("/object_templates/tv/relatable_categories?api_key=#{@user.api_key}", {:related_attribute => "manufacture"}, { 'HTTP_ACCEPT' => 'application/json'})
      json = JSON.parse(response.body)["object_template"]
      json["relatable_categories"].should have(5).entries
    end
  end
  
  
  describe "GET /object_templates/:name/generic_objects/filter (HTTP_ACCEPT json) Given object exists with some relatable categories" do
     before(:each) do
       @user = ApiUser.make
       @user.activate!

       @template = ObjectTemplate.make(:name => "tv", 
         :relatable_characteristics => [
           {:attribute => "manufacture", :value_type => "String"},
           {:attribute => "screen_size", :value_type => "String"}
         ],
         :formula_inputs => [
           {:name => "kilogram", :model_state => "active", :active_at => Time.now, :input_units => "kg/year", :label_input_units => "Kilogram units per yeah", :values => {"kilo" => 12}}
         ]
       )
       @object_plan = GenericObject.plan(:object_template_id => @template.id)
       @object = GenericObject.new(@object_plan)
       @object.stub_characteristics_from_template!
       @object.relatable_characteristics[0].value = "sony"
       @object.relatable_characteristics[1].value = "41"
       @object.characteristics.each{|c|c.value = "stub"}
       if label = @object.characteristics.detect{|c| c["attribute"] == "label"}
         label.value = "egg"
       end
       @object.save!


       @object_plan = GenericObject.plan(:object_template_id => @template.id)
       @object2 = GenericObject.new(@object_plan)
       @object2.stub_characteristics_from_template!
       @object2.relatable_characteristics[0].value = "panasonic"
       @object2.relatable_characteristics[1].value = "45"
       @object2.characteristics.each{|c|c.value = "stub"}
       if label = @object2.characteristics.detect{|c| c["attribute"] == "label"}
         label.value = "beans"
       end
       @object2.save!
     end

     it "should find a generic object form searching with 'egg'" do
       response = get("/object_templates/tv/generic_objects/filter?api_key=#{@user.api_key}", {:filter => "egg"}, { 'HTTP_ACCEPT' => 'application/json'})
       json = JSON.parse(response.body)
       json.should_not be_empty
       json["object_template"]["generic_objects"].should == [JSON.parse(@object.attributes_for_api_resources.to_json)]
     end

     it "should find a generic object form searching with 'beans'" do
       response = get("/object_templates/tv/generic_objects/filter?api_key=#{@user.api_key}", {:filter => "beans", :relatable_category_values => ["panasonic"]}, { 'HTTP_ACCEPT' => 'application/json'})
       json = JSON.parse(response.body)
       json.should_not be_empty
       json["object_template"]["generic_objects"].should == [JSON.parse(@object2.attributes_for_api_resources.to_json)]
     end

     it "should find a generic object form searching with 'beans' and related_attribute name of panasonic" do
       response = get("/object_templates/tv/generic_objects/filter?api_key=#{@user.api_key}", {:filter => "beans", :relatable_category_values => ["panasonic", "45"]}, { 'HTTP_ACCEPT' => 'application/json'})
       json = JSON.parse(response.body)
       json.should_not be_empty
       json["object_template"]["generic_objects"].should == [JSON.parse(@object2.attributes_for_api_resources.to_json)]
     end

     it "should not find a generic object form searching with 'beans' and related_attribute name of panasonic 41" do
       response = get("/object_templates/tv/generic_objects/filter?api_key=#{@user.api_key}", {:filter => "beans", :relatable_category_values => ["panasonic", "41"]}, { 'HTTP_ACCEPT' => 'application/json'})
       json = JSON.parse(response.body)
       json.should_not be_empty
       json["object_template"]["generic_objects"].should == []
     end
   end
end
