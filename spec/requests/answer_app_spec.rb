require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "GenericObjectApp" do
  def app
    @app = Rack::Builder.app do
      run CarbonCalculatedApi::AnswerApp
    end
  end
   
  describe "Simple Calculator with 2 computations" do
    before(:each) do
      @user = ApiUser.make
      @user.activate!
      
      @calculator = Calculator.make
      @computation1 = Computation.make(:calculator => @calculator) 
      @answer_set1 = AnswerSet.make(:computation_id => @computation1.id)
      @answer_set1.equations << Equation.new(:formula => "10*value(:answer_set1)")
      @answer_set1.save!
      @answer_choice1 = AnswerChoices::Variable.make(:name => "answer_set1", :answer_set_id => @answer_set1.id)
      Validations::Presence.make(:validatable => @answer_choice1)

      @computation2 = Computation.make(:calculator => @calculator) 
      @answer_set2 = AnswerSet.make(:computation_id => @computation2.id)
      @answer_set2.equations << Equation.new(:formula => "20*value(:answer_set2)")
      @answer_set2.save!
      @answer_choice2 = AnswerChoices::Variable.make(:name => "answer_set2", :answer_set_id => @answer_set2.id)
      Validations::Presence.make(:validatable => @answer_choice2)

      @computation3 = Computation.make(:calculator => @calculator) 
      @answer_set3 = AnswerSet.make(:computation_id => @computation3.id)
      @answer_set3.equations << Equation.new(:formula => "30*value(:answer_set3)")
      @answer_set3.save!
      @answer_choice3 = AnswerChoices::Variable.make(:name => "answer_set3", :answer_set_id => @answer_set3.id)
      Validations::Presence.make(:validatable => @answer_choice3)

      @answer_set1.activate!
      @answer_set2.activate!
      @answer_set3.activate!
    end
    
    describe "GET /calculators/:calculator_id/answer.json", "Given not all the option have been given" do 
      it "should give the calculation as we have passed a valid computation" do
        response = get("/calculators/#{@calculator.id}/answer?api_key=#{@user.api_key}", {"answer_set1" => 10}, { 'HTTP_ACCEPT' => 'application/json'})
        json = JSON.parse(response.body)  
        json.should == {"calculations"=>{"co2"=>{"value"=>100.0, "units"=>"kg/year"}}, "answer_set_id"=>@calculator.computations.first.answer_sets[0].id.to_s, "source"=>{"id"=>"4ca46555dfde7b4219000005", "description"=>"egg", "main_source_ids"=>[], "external_url"=>nil, "wave_id"=>nil}, "calculator_id"=>@calculator.id.to_s, "computation_id"=>@calculator.computations.first.id.to_s, "object_references"=>{}, "used_global_computations"=>{}}    
      end
      
      it "should give the error as the computation does not exist" do
        response = get("/calculators/#{@calculator.id}/answer?api_key=#{@user.api_key}", {"blar" => 10}, { 'HTTP_ACCEPT' => 'application/json'})
        json = JSON.parse(response.body)
        json.should == {"errors"=>["Please supply all the required values"]}
      end
    end
  end
  
  
  describe "Calculator Errors No Calculator" do
    before(:each) do
      @user = ApiUser.make
      @user.activate!
      
      @calculator = Calculator.make
      @computation1 = Computation.make(:calculator => @calculator) 
      @answer_set1 = AnswerSet.make(:computation_id => @computation1.id)
      @answer_set1.equations << Equation.new(:formula => "99*value(:answer_set1)")
      @answer_set1.save!
      @answer_choice1 = AnswerChoices::Variable.make(:name => "answer_set1", :answer_set_id => @answer_set1.id)
      Validations::Presence.make(:validatable => @answer_choice1)
    end
    
    describe "GET /calculators/:calculator_id/answer.json", "Given not all the option have been given" do 
      it "should raise Calculator::Error as we have passed an invalid  answer basically computation" do
        response = get("/computations/#{@computation1.id}/answer?api_key=#{@user.api_key}", {"answer_set1" => 'cheese'}, { 'HTTP_ACCEPT' => 'application/json'})
        json = JSON.parse(response.body)
        json.should == {"errors"=>{"base"=>"No answer available"}}
      end
    end
  end

end
