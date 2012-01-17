require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Answer" do
  describe "When initialing Given a calculator exist with length validation attached to an answer choice" do
    before(:each) do
      @calculator = Calculator.make
      @computation = Computation.make(:calculator => @calculator)
      @answer_set = AnswerSet.make(:computation_id => @computation.id)
      @answer_set.activate!
      @answer_choice = AnswerChoices::Variable.make(:name => "random_text", :answer_set_id => @answer_set.id)
      @validation = Validations::Presence.make(:validatable => @answer_choice)
      @validation = Validations::Length.make(:options => {"within" => '5..10'}, :validatable => @answer_choice)
    end
    
    describe "with an answer that has the correct variable and length" do
      before(:each) do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"random_text" => "iscool"}, :computation_id => @computation.id})
        @answer.validations = @answer_choice.validations
      end
  
  
      it "should be valid" do
       @answer.should be_valid
      end
    end
    
    describe "with an answer that has the incorrect variable length" do
      before(:each) do       
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"random_text" => "poo"}, :computation_id => @computation.id})
        @answer.validations = @answer_choice.validations
      end
      
      it "should not be valid" do
       @answer.should_not be_valid
      end
    end
  end
  
  describe "When initialing Given a calculator exist with inclusion validation attached to an answer choice" do
     before(:each) do
       @calculator = Calculator.make
       @computation = Computation.make(:calculator => @calculator)
       @answer_set = AnswerSet.make(:computation_id => @computation.id)
       @answer_set.activate!
       @answer_choice = AnswerChoices::Variable.make(:name => "beans", :answer_set_id => @answer_set.id)
       @validation = Validations::Inclusion.create!(
        :validatable => @answer_choice,
        :options => {
          :in => "0.0..1.0"
        })
     end
     
     it "should be valid when a number is between the rante 0.0 and 1.0" do
       @answer = Answer.new({
         :calculator_id => @calculator.id, 
         :answer => {"beans" => "0.4"}, 
         :computation_id => @computation.id}
        )
       @answer.should be_valid
     end
     
     it "should not be valid when a number is between the rante 0.0 and 1.0" do
       @answer = Answer.new({
         :calculator_id => @calculator.id, 
         :answer => {"beans" => "1.1"}, 
         :computation_id => @computation.id}
        )
       @answer.should_not be_valid
     end
   end

  describe "When initialing Given a calculator exist with presence and numerial validations attached to the a answer_choice" do
    before(:each) do
      @calculator = Calculator.make
      @computation = Computation.make(:calculator => @calculator)
      @answer_set = AnswerSet.make(:computation_id => @computation.id)
      @answer_set.activate!
      @answer_choice = AnswerChoices::Variable.make(:name => "no_of_people", :answer_set_id => @answer_set.id)
      @validation = Validations::Presence.make(:validatable => @answer_choice)
      @validation = Validations::Numericality.make(:validatable => @answer_choice)
    end
    
      describe "with answer with the incorrect name for the answer choice variable" do
        before(:each) do
          @answer = Answer.new  ({:calculator_id => @calculator.id, :answer => {"egg" => "4"}, :computation_id => @computation.id})
          @answer.validations = @answer_choice.validations
        end

        it "should be valid?" do
          @answer.should_not be_valid  
        end
        
        it "should have an no_of_people error" do
          @answer.should_not be_valid  
          @answer.errors[:no_of_people].should == ["can't be blank", "is not a number"]
        end
      end
      
      describe "with answer with the incorrect name for the answer choice variable" do
        before(:each) do
          @answer = ::Answer.new({:calculator_id => @calculator.id, :answer => {"no_of_people" => "egg"}, :computation_id => @computation.id})
          @answer.validations = @answer_choice.validations
        end

        it "should be valid?" do
          @answer.should_not be_valid
        end
        
        it "should have an no_of_people error" do
          @answer.should_not be_valid  
          @answer.errors[:no_of_people].should == ["is not a number"]
        end
      end
    
    
    describe "with answer with the correct name for the answer choice variable" do
      before(:each) do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"no_of_people" => "4"}, :computation_id => @computation.id})
        @answer.validations = @answer_choice.validations
      end
      
      it "should be valid?" do
        @answer.should be_valid
      end
    end
  end
  
  describe "Given Calculator exists with a computation And characteristics validations are being used" do
    before(:each) do
      
      @template = ObjectTemplate.make(:name => "TV", 
        :characteristics => [{:attribute => "name", :value_type => "String"}, {:attribute => "year", :value_type => "Integer"} ,{:attribute => "label", :value_type => "String"}], 
        :relatable_characteristics => [{:attribute => "manufacture", :value_type => "String"}]
      )
      
      @object_plan = GenericObject.plan(:object_template_id => @template.id)
      @object1 = GenericObject.new(@object_plan)
      @object1.stub_characteristics_from_template!
      label = @object1.characteristics.detect{|c| c.attribute == "label"}
      label.value = "object1"
      @object1.relatable_characteristics[0].value = "sony"
      @object1.characteristics.each{|c|c.value = "stub"}
      @object1.characteristics[0].value = "beans"
      @object1.save!
      
            
      @object_plan = GenericObject.plan(:object_template_id => @template.id)
      @object2 = GenericObject.new(@object_plan)
      @object2.stub_characteristics_from_template!
      
      @object2.characteristics.each{|c|c.value = "stub"}
      name = @object2.characteristics.detect{|c| c.attribute == "name"}
      @object2.characteristics.delete(name)
  
      @object2.relatable_characteristics[0].value = "sony"
      label = @object2.characteristics.detect{|c| c.attribute == "label"}
      label.value = "object2"
      
      year = @object2.characteristics.detect{|c| c.attribute == "year"}
      year.value = 2006
      
      @object2.save!
      
      @object_plan = GenericObject.plan(:object_template_id => @template.id)
      @object3 = GenericObject.new(@object_plan)
      @object3.stub_characteristics_from_template!
      @object3.relatable_characteristics[0].value = "sony"
      @object3.characteristics.each{|c|c.value = "stub"}
      label = @object3.characteristics.detect{|c| c.attribute == "label"}
      label.value = "object3"
      
      year = @object3.characteristics.detect{|c| c.attribute == "year"}
      year.value = 2005
      
      @object3.save!
      
      @calculator = Calculator.make
      @computation = Computation.make(:calculator => @calculator)
      @answer_set = AnswerSet.make(:computation_id => @computation.id)
      @answer_set.activate!
      @answer_choice = AnswerChoices::ObjectReference.create!(:name => "egg", :answer_set_id => @answer_set.id, :object_name => "tv")      
    end
    
    describe "#valid Given answer has object reference with a characteristic condition validation with 2006 on its year characteristic" do
      before(:each) do
        @validation = Validations::CharacteristicCondition.create!(:validatable => @answer_set, :options => {:name => "egg", :characteristic_attribute => "year", :condition => "input >= 2006"})
      end
      
      it "should be valid if we supply an answer with an generic object 'egg that has year 2006" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object2.id.to_s}, :computation_id => @computation.id})
        @answer.should be_valid
      end
      
      it "should not be valid if we supply an answer with an 'egg' object with a year of 2005" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object3.id.to_s}, :computation_id => @computation.id})
        @answer.should_not be_valid
      end
    end 
    
    describe "#valid Given answer has object reference And characteristic just has to be present" do
      before(:each) do
        @validation = Validations::MustHaveCharacteristic.make(:validatable => @answer_choice, :options => {:name => "egg", :characteristic_attribute => "name"})
      end
      
      it "should be valid with an object that has a name characteristic" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object1.id.to_s}, :computation_id => @computation.id})
        @answer.should be_valid
      end
      
      it "should not be valid with an object does not have the name characteristic" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object2.id.to_s}, :computation_id => @computation.id})
        @answer.should_not be_valid
      end
    end
    
    describe "#valid Given answer has object reference And the characteristic needs to exist with specific value" do
      before(:each) do
        @validation = Validations::MustHaveCharacteristic.make(:validatable => @answer_choice, :options => {:name => "egg", :characteristic_attribute => "name", :characteristic_value => "beans"})
      end
      
      it "should be valid with an object that has a name characteristic" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object1.id.to_s}, :computation_id => @computation.id})
        @answer.should be_valid
      end
      
      it "should not be valid with an object does not have the name characteristic" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object3.id.to_s}, :computation_id => @computation.id})
        @answer.should_not be_valid
      end
    end
    
    describe "#valid Given answer has object reference And the characteristic should not be present for that object" do
      before(:each) do
        @validation = Validations::MustNotHaveCharacteristic.make(:validatable => @answer_choice, :options => {:name => "egg", :characteristic_attribute => "name"})
      end
      
      it "should be valid with an object that has a name characteristic" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object1.id.to_s}, :computation_id => @computation.id})
        @answer.should_not be_valid
      end
      
      it "should not be valid with an object does not have the name characteristic" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object2.id.to_s}, :computation_id => @computation.id})
        @answer.should be_valid
      end
    end
    
    
    describe "#valid Given answer has object reference And the characteristic should not be present for that object with values as well" do
      before(:each) do
        @validation = Validations::MustNotHaveCharacteristic.make(:validatable => @answer_choice, :options => {:name => "egg", :characteristic_attribute => "name", :characteristic_value => "beans"})
      end
      
      it "should be valid with an object that has a name characteristic" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object1.id.to_s}, :computation_id => @computation.id})
        @answer.should_not be_valid
      end
      
      it "should not be valid with an object does not have the name characteristic" do
        @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"egg" => @object3.id.to_s}, :computation_id => @computation.id})
        @answer.should be_valid
      end
    end
  end
  
  describe "Answer Given a variable that must meet a condition" do
    before(:each) do
      @calculator = Calculator.make
      @computation = Computation.make(:calculator => @calculator)
      @answer_set = AnswerSet.make(:computation_id => @computation.id)
      @answer_set.activate!
      @answer_choice = AnswerChoices::Variable.make(:name => "random_text", :answer_set_id => @answer_set.id)
      @validation = Validations::Condition.create!(:validatable => @answer_choice, :options => {:name => "random_text", :condition => "input != 'egg'"})

    end
    
    it "should be valid if the answer does not contain the answer 'egg'" do
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"random_text" => "beans"}, :computation_id => @computation.id})
      @answer.should be_valid      
    end
    
    it "should be valid if the answer does not contain the answer 'egg'" do
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"random_text" => "egg"}, :computation_id => @computation.id})
      @answer.should_not be_valid
    end
  end
  
  describe "Answer Given at least one variable must meet a condition" do
    before(:each) do
      @calculator = Calculator.make
      @computation = Computation.make(:calculator => @calculator)
      @answer_set = AnswerSet.make(:computation_id => @computation.id)
      @answer_set.activate!
      @answer_choice1 = AnswerChoices::Variable.make(:name => "random_text", :answer_set_id => @answer_set.id)      
      @answer_choice2 = AnswerChoices::Variable.make(:name => "other", :answer_set_id => @answer_set.id)
      @answer_choice3 = AnswerChoices::Variable.make(:name => "other_another", :answer_set_id => @answer_set.id)      
      @answer_choice4 = AnswerChoices::Variable.make(:name => "another", :answer_set_id => @answer_set.id)
      @validation = Validations::OneOfManyWithCondition.create!(
        :validatable => @answer_set, 
        :options => {
            :names => ["random_text", "other", "other_another", "another"], 
            :condition => "input > 0"
        })
    end
    
    it "should be valid if at least on the boys contains a value that is greater then 0" do
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"random_text" => "1"}, :computation_id => @computation.id})
      @answer.should be_valid
      
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"random_text" => "1", "other" => "3", "another" => "-10"}, :computation_id => @computation.id})
      @answer.should be_valid   
      
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"another" => "100.8"}, :computation_id => @computation.id})
      @answer.should be_valid
    end
    
    it "should not be valid if none are > 0" do
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"random_text" => "-10"}, :computation_id => @computation.id})
      @answer.should_not be_valid
      
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {}, :computation_id => @computation.id})
      @answer.should_not be_valid
    end
  end
  
  describe "Answer Given we are answering a calculator with 3 computations" do
    before(:each) do
      @calculator = Calculator.make
      @computation1 = Computation.make(:calculator => @calculator) 
      @answer_set1 = AnswerSet.make(:computation_id => @computation1.id)
      @answer_set1.equations << Equation.new(:formula => "10*value(:answer_set1)")
      @answer_set1.save
      @answer_choice1 = AnswerChoices::Variable.make(:name => "answer_set1", :answer_set_id => @answer_set1.id)
      Validations::Presence.make(:validatable => @answer_choice1)
      
      @computation2 = Computation.make(:calculator => @calculator) 
      @answer_set2 = AnswerSet.make(:computation_id => @computation2.id)
      @answer_set2.equations << Equation.new(:formula => "20*value(:answer_set2)")
      @answer_set2.save
      @answer_choice2 = AnswerChoices::Variable.make(:name => "answer_set2", :answer_set_id => @answer_set2.id)
      Validations::Presence.make(:validatable => @answer_choice2)
      
      @computation3 = Computation.make(:calculator => @calculator) 
      @answer_set3 = AnswerSet.make(:computation_id => @computation3.id)
      @answer_set3.equations << Equation.new(:formula => "30*value(:answer_set3)")
      @answer_set3.save
      @answer_choice3 = AnswerChoices::Variable.make(:name => "answer_set3", :answer_set_id => @answer_set3.id)
      Validations::Presence.make(:validatable => @answer_choice3)
      
      @answer_set1.activate!
      @answer_set2.activate!
      @answer_set3.activate!
    end
    
    it "should only answer the relavent computation when answer answer_set3 => 10" do
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"answer_set3" => "10"}})
      @answer.calculate.should == {:calculations=>{"co2"=>{"value"=>300.0, "units"=>"kg/year"}}, :answer_set_id=>@answer_set3.id.to_s, :source=>{"id"=>BSON::ObjectId('4ca46555dfde7b4219000005'), "description"=>"egg", "main_source_ids"=>[], "external_url"=>nil, "wave_id"=>nil}, :calculator_id=>@calculator.id.to_s, :computation_id=>@computation3.id.to_s, :object_references=>{}, :used_global_computations=>{}}
    end
    
    it "should only answer the relavent computation when answer answer_set2 => 10" do
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"answer_set2" => "10"}})
      @answer.calculate.should == {:calculations=>{"co2"=>{"value"=>200.0, "units"=>"kg/year"}}, :answer_set_id=>@answer_set2.id.to_s, :source=>{"id"=>BSON::ObjectId('4ca46555dfde7b4219000005'), "description"=>"egg", "main_source_ids"=>[], "external_url"=>nil, "wave_id"=>nil}, :calculator_id=>@calculator.id.to_s, :computation_id=>@computation2.id.to_s, :object_references=>{}, :used_global_computations=>{}}
    end
    
    it "should only answer the relavent computation when answer answer_set1 => 10" do
      @answer = Answer.new({:calculator_id => @calculator.id, :answer => {"answer_set1" => "10"}})
      @answer.calculate.should == {:calculations=>{"co2"=>{"value"=>100.0, "units"=>"kg/year"}}, :answer_set_id=>@answer_set1.id.to_s, :source=>{"id"=>BSON::ObjectId('4ca46555dfde7b4219000005'), "description"=>"egg", "main_source_ids"=>[], "external_url"=>nil, "wave_id"=>nil}, :calculator_id=>@calculator.id.to_s, :computation_id=>@computation1.id.to_s, :object_references=>{}, :used_global_computations=>{}}
    end
    
    it "should not be valid if no valid answer set is given" do
      @answer = Answer.new({:calculator_id => @calculator.id.to_s, :calculator_id => @calculator.id, :answer => {"answer_set4" => "10"}})
      @answer.should_not be_valid
      @answer.errors.should == ["Please supply all the required values"]
    end
  end
  
end
