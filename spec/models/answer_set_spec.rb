require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "AnswerSet" do
  describe "Given an answer set with an equation value(:egg)*value(:beans)" do
    before(:each) do
      @computation = Computation.make
      @answer_set = AnswerSet.make(:computation_id => @computation.id)
      @answer_set.equations << Equation.new(:formula => "value(:eggs)*value(:beans)")
      @answer_set.save
      @answer_choice1 = AnswerChoices::Variable.make(:name => "eggs", :answer_set => @answer_set)
      @answer_choice2 = AnswerChoices::Variable.make(:name => "beans", :answer_set => @answer_set)
      @cal_answer = Answer.new({:computation_id => @computation.id, :answer => {}})
      @cal_answer.stub!(:used_global_computations).and_return({})
    end
    
    describe "#calculate" do
      it "should equal {'co2' => 8} Given an answer of :egg => 2, :beans => 4" do
        @answer = {"beans" => 2, "eggs" => 4}
        @answer_set.calculate(@cal_answer, @answer).should == {"co2"=>{"value"=>8.0, "units"=>"kg/year"}}
        
      end
    end
  end
  
  
  describe "Given an answer set with an equation 'value(:egg)*compute(:distance, value(:beans))'" do
    before(:each) do
      @computation = Computation.make
      @answer_set = AnswerSet.make(:computation_id => @computation.id)
      @answer_set.equations << Equation.new(:formula => "value(:eggs)*compute(:distance_times_10, :distance => value(:beans))")
      @answer_set.save
      @answer_choice1 = AnswerChoices::Variable.make(:name => "eggs", :answer_set => @answer_set)
      @answer_choice2 = AnswerChoices::Variable.make(:name => "beans", :answer_set => @answer_set)
      @distance_times_10 = GlobalComputation.create!(
        :name => "distance_times_10", 
        :parameters => [:distance],
        :equation => "value(:distance)*10"
      )
      @cal_answer = Answer.new({:computation_id => @computation.id, :answer => {}})
      @cal_answer.stub!(:used_global_computations).and_return({})
    end
    
      describe "#calculate" do
        it "should equal {'co2' => 80} Given an answer of :eggs => 2, :beans => 4" do
          @answer = {"beans" => 2, "eggs" => 4}
          @answer_set.calculate(@cal_answer, @answer).should == {"co2"=>{"value"=>80.0, "units"=>"kg/year"}}
        end
      end
    end
    
       describe "Given an answer set with an equation 'value(:no_of_persons)*3 from options'" do
         before(:each) do
           @computation = Computation.make
           @answer_set = AnswerSet.make(:computation_id => @computation.id)
           @answer_set.equations << Equation.new(:formula => "value(:shit_factor)*3")
           @answer_choice1 = AnswerChoices::Option.make(:name => "shit_factor", :answer_set => @answer_set, :options => {"leona" => 2, "berk" => 10})
           @cal_answer = Answer.new({:computation_id => @computation.id, :answer => {}})
           @cal_answer.stub!(:used_global_computations).and_return({})
         end
     
         describe "#calculate" do
           it "should equal 12 Given an answer of :shit_factor => 'leona'" do
             @answer = {"shit_factor" => 'leona'}
             @answer_set.calculate(@cal_answer, @answer).should == {"co2"=>{"value"=>6.0, "units"=>"kg/year"}}
           end
           
           it "should equal 12 Given an answer of :shit_factor => 'berk'" do
             @answer = {"shit_factor" => 'berk'}
             @answer_set.calculate(@cal_answer, @answer).should == {"co2"=>{"value"=>30.0, "units"=>"kg/year"}}
           end
         end
       end
     end
       
     describe "Given we have a object reference with formula_inputs" do
       before(:each) do
         @template = ObjectTemplate.make(:name => "TV", 
           :formula_inputs => [
             {
               :name => "per_watt", 
               :values => {"co2" => 12, "no4" => 123, "ch4" => 12}, 
               :input_units => "watt/hour", 
               :label_input_units => "watts per hour",
               :active_at => Time.now-1.year,
               :model_state => "active"
             }
           ], 
           :relatable_characteristics => []
           )
         @object_plan = GenericObject.plan(:object_template_id => @template.id)
         @object = GenericObject.new(@object_plan)
         @object.stub_characteristics_from_template!
         @object.characteristics.each{|c|c.value = "stub"}
         @object.save!
         
         @computation = Computation.make
         @answer_set = AnswerSet.make(:computation_id => @computation.id)
         @answer_set.activate!
         @answer_set.equations << Equation.new(:formula => "formula(:watt, :per_watt, :co2)*3")
         @answer_set.save
         @answer_choice = AnswerChoices::ObjectReference.make(
           :name => "watt", 
           :answer_set => @answer_set,
           :object_name => "tv"
         )
         @answer = Answer.new({:computation_id => @computation.id, :answer => {}})
         @answer.stub!(:used_global_computations).and_return({})
       end
       
       describe "#calculate given object has 1 active formula_input" do
         it "should give a co2 of 36.0 based on the answer given the correct object" do
           @computation.calculate(@answer, {"watt" => @object.id.to_s}).should == {"co2"=>{"value"=>36.0, "units"=>"kg/year"}}
         end
         
         it "should give co2 of 9 as the active formula_input has changed" do
           @object.formula_inputs << FormulaInput.new(
             :name => "per_watt", 
             :values => {"co2" => 3, "no4" => 123, "ch4" => 12}, 
             :input_units => "watt/hour", 
             :label_input_units => "watts per hour",
             :active_at => Time.now-3.months,
             :model_state => "active"
           )
           @object.save!
           @computation.calculate(@answer, {"watt" => @object.id.to_s}).should == {"co2"=>{"value"=>9.0, "units"=>"kg/year"}}
         end
       end
     end
       
       
     describe "Given we have a object reference with formula_inputs; And it has validations for the formula input for the model reference" do
       before(:each) do
         @template = ObjectTemplate.make(:name => "TV", 
           :formula_inputs => [
             {
               :name => "per_watt", 
               :values => {"co2" => 12, "no4" => 123, "ch4" => 12}, 
               :input_units => "watt/hour", 
               :label_input_units => "watts per hour",
               :active_at => Time.now-1.year,
               :model_state => "active"
              }
            ], 
           :relatable_characteristics => []
         )
         @object_plan = GenericObject.plan(:object_template_id => @template.id)
         @object = GenericObject.new(@object_plan)
         @object.stub_characteristics_from_template!
         @object.characteristics.each{|c|c.value = "stub"}
         @object.save!
     
         @computation = Computation.make
         @answer_set = AnswerSet.make(:computation_id => @computation.id)
         @answer_set.activate!
         @answer_set.equations << Equation.new(:formula => "formula(:watt, value(:units), :co2)")
         @answer_set.save
         @answer_choice = AnswerChoices::ObjectReference.make(
           :name => "watt", 
           :answer_set => @answer_set,
           :object_name => "tv"
         )
         Validations::Presence.make(:validatable => @answer_choice)
          
         @units = AnswerChoices::Select.create!(:name => "units", :answer_set => @answer_set)
         Validations::Presence.make(:validatable => @units)
          
         Validations::MustHaveFormulaInputName.create!(
           :validatable => @answer_set,
           :options => {
             :name => "units",
             :object_reference_name => "watt"
           }
         )
       end
     
       describe "Asking if the answer is valid" do
         it "it should be valid if the units given has name 'watt'" do
           @answer = Answer.new({:computation_id => @computation.id, :answer => {"watt" => @object.id.to_s, "units" => "per_watt"}})
           @answer.should be_valid
         end
     
         it "should not be valid if the name is a formula inputs not found in the object" do
           @answer = Answer.new({:computation_id => @computation.id, :answer => {"watt" => @object.id.to_s, "units" => "something random"}})
           @answer.should_not be_valid
         end
      end
end
