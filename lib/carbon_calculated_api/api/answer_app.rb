module CarbonCalculatedApi
  class AnswerApp < API::App
        
    error 500 do
      {:errors => {:base => request.env['sinatra.error'].message}}.to_json
    end

    get "/computations/:computation_id/answer.json" do |computation_id|
      @answer = Answer.new({:computation_id => computation_id, :answer => params, :calculation_time => params[:calculation_time]})
      @answer.calculate.to_json
    end
    
    post "/computations/:computation_id/answer.json" do |computation_id|
      @answer = Answer.new({:computation_id => computation_id, :answer => params, :calculation_time => params[:calculation_time]})
      @answer.calculate.to_json
    end
  
    get "/calculators/:calculator_id/answer.json" do |calculator_id|
      @answer = Answer.new({:calculator_id => calculator_id, :answer => params, :calculation_time => params[:calculation_time]})
      @answer.calculate.to_json
    end

    post "/calculators/:calculator_id/answer.json" do |computation_id|
      puts "DSFGJFDSOGJFDOGJO #{params.inspect}"
      @answer = Answer.new({:calculator_id => computation_id, :answer => params, :calculation_time => params[:calculation_time]})
      @answer.calculate.to_json
    end
    
  end
end
