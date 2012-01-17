require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Computation Answer Set" do  
  describe "#calculate given answer {:beans => 'eggs', milk => 'cheese'}, and activated answer set" do
     before(:each) do
       @computation = Computation.make(:name => "testing")
       @answer_set = AnswerSet.make(:computation => @computation)
       @answer_set.equations << Equation.new(:formula => "value(:eggs)*value(:beans)")
       @answer_set.activate!
       @answer_choice1 = AnswerChoices::Variable.make(:name => "eggs", :answer_set => @answer_set)
       @answer_choice2 = AnswerChoices::Variable.make(:name => "beans", :answer_set => @answer_set)
     end
     
     it "should delagate to the answer set for a calculation" do
       @answer = {"beans" => 2, "eggs" => 4}
       @computation.calculate(nil, @answer).should == {"co2"=>{"value"=>8.0, "units"=>"kg/year"}}
     end
   end
   
   describe "#calculate given answer {:beans => 'eggs', milk => 'cheese'}, none activated answer set" do
      before(:each) do
        @computation = Computation.make(:name => "testing")
        @answer_set = AnswerSet.make(:computation => @computation)
        @answer_set.equations << Equation.new(:formula => "value(:eggs)*value(:beans)")
        @answer_set.save
        @answer_choice1 = AnswerChoices::Variable.make(:name => "eggs", :answer_set => @answer_set)
        @answer_choice2 = AnswerChoices::Variable.make(:name => "beans", :answer_set => @answer_set)
      end

      it "should raise Exception" do
        lambda{@computation.calculate(nil, @answer)}.should raise_error(Calculator::NoCalculationExistsError)
      end
    end
    
    describe "#calculate given answer {:beans => 'eggs', milk => 'cheese'}, with 2 activataed answer_sets with different activation times" do
       before(:each) do
         @computation = Computation.make(:name => "testing")
         @answer_set = AnswerSet.make(:computation => @computation)
         @answer_set.equations << Equation.new(:formula => "value(:eggs)*value(:beans)")
         @answer_set.save
         @answer_set.active_at = Time.now - 2.years
         @answer_set.model_state = "active"
         @answer_set.save
         
         @answer_set2 = AnswerSet.make(:computation => @computation)
         @answer_set2.equations << Equation.new(:formula => "20*(value(:eggs)*value(:beans))")
         @answer_set2.activate!
         
         @answer_set3 = AnswerSet.make(:computation => @computation)
         @answer_set3.equations << Equation.new(:formula => "10*(value(:eggs)*value(:beans))")
         @answer_set3.active_at = Time.now - 19.months
         @answer_set3.model_state = "active"
         @answer_set3.save
                          
         @answer_choice1 = AnswerChoices::Variable.make(:name => "eggs", :answer_set => @answer_set)
         @answer_choice2 = AnswerChoices::Variable.make(:name => "beans", :answer_set => @answer_set)
         
         @answer_choice3 = AnswerChoices::Variable.make(:name => "eggs", :answer_set => @answer_set2)
         @answer_choice4 = AnswerChoices::Variable.make(:name => "beans", :answer_set => @answer_set2)
         
         
         @answer_choice5 = AnswerChoices::Variable.make(:name => "eggs", :answer_set => @answer_set3)
         @answer_choice6 = AnswerChoices::Variable.make(:name => "beans", :answer_set => @answer_set3)
       end

       it "should get the most current answer set if not calculation time given" do
         @answer = {"beans" => 2, "eggs" => 4}
         @computation.calculate(nil, @answer).should == {"co2"=>{"value"=>160.0, "units"=>"kg/year"}}
       end
       
       it "should get the most current answer set calculation time given is 2 years ago" do
         @answer = {"beans" => 2, "eggs" => 4}
         @computation.calculation_time = Time.now - 18.months
         @computation.calculate(nil, @answer).should == {"co2"=>{"value"=>80.0, "units"=>"kg/year"}}
       end
       
       it "should get the most current answer set calculation time given is 2 years ago" do
         @answer = {"beans" => 2, "eggs" => 4}
         @computation.calculation_time = Time.now - 20.months
         @computation.calculate(nil, @answer).should == {"co2"=>{"value"=>8.0, "units"=>"kg/year"}}
         
       end
     end
end

