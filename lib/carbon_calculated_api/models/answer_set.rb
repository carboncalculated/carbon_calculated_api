class AnswerSet
  include MongoMapper::Document
  include CarbonCalculatedApi::Model
  
  # == Keys
  key :computation_id, ObjectId
  key :_type, String
  key :active_at, Time
  key :source, Source
  timestamps!
  
  # == Indexes
  ensure_index "equations.equation_type"
  ensure_index :active_at
  
  # == Associations
  belongs_to :computation
  many :answer_choices
  many :answer_set_validations, :as => :validatable, :class_name => "Validation"
  
  # allows computation to find the answer_set_id
  def answer_set_id
    self.id
  end
  
  def answer_set_source
    self.source.attributes_for_api_resources
  end

  def validations
    @validations ||= (self.answer_set_validations + answer_choices.map(&:validations)).flatten
  end

  # How does this work?
  # in the equation string just do the following
  # @example
  #   value(:name)*value(:whatever)*characteristics(:transport, :lat1)*formula(:transport, :per_km, :co2)
  #   therefore each value will find its answer_choice and ask what
  #   its computed value
  # @return [Array<Hash>] [{:co2 => 12.434, :units => "kg"}]
  def calculate(calculating_answer, answer = {})
    @calculating_answer = calculating_answer
    @answer = answer.with_indifferent_access
    equations.inject({}) do |var, equation|
      if equation_value = instance_eval(equation["formula"]) # if the equation brings back false then dont use!!!
        var.merge!(equation["equation_type"] => {"value" => equation_value.to_f.round(6), "units" => equation["units"]})
      end
      var
    end
  rescue Calculator::GenericObjectNotFound => e
    raise Calculator::CalculationError, e.message
  rescue Exception => e
    puts "#{e.message} ::: #{e.backtrace}"
    raise Calculator::CalculationError, "Calculation could not be reached"
  end

  # Method called with the equation eval;
  # this will find the the ch
  # @param [Symbol, #to_s] choice_name
  def value(choice_name)
    if answer_choice = answer_choices.first(:name => choice_name.to_s)
      answer_value = @answer[choice_name.to_s]
      answer_choice.value(@calculating_answer, answer_value) if answer_value
    end
  end
  
  # @param [Symbol, #to_s] choice_name
  # @param [Symbol] formula_input_name
  # @param [Symbol] value_key
  # @return [Float] computed formula result
  def formula(choice_name, formula_input_name, value_key)
    if answer_choice = answer_choices.first(:name => choice_name.to_s)
      answer_value = @answer[choice_name.to_s]
      answer_choice.value(@calculating_answer, answer_value, formula_input_name, value_key, self.active_at) if answer_value
    end
  end
  
  # @param [Symbol, #to_s] choice_name
  # @param [Symbol] attribute
  # @return [Float] computed characteristic value from the characteristic_name
  #
  # These are to be used mosly in further compute functions ie distance from 
  # a lat1, lng1, lat2, lng2 for instance to calculate the distance; therefore
  # your object will need to have these characteristics to get the values
  # to calculate the distance
  def characteristic(choice_name, characteristic_name, method = nil)
    if answer_choice = answer_choices.first(:name => choice_name.to_s)
      answer_value = @answer[choice_name.to_s]
      if answer_value
        value = answer_choice.characteristic_value(@calculating_answer, answer_value, characteristic_name)
        value.send(method) if method
      end
    end
  end
  
  # For is for using global computations basically via 
  # setting the names that it required correct and then
  # using the answer_choices if one wishes to get some
  # values to complete the calculation
  #
  # @param [Symbol, #to_s] name
  # @param [Hash] values the actual mappings of the parameters to the
  #   computation
  def compute(name, values = {})
    computation = GlobalComputation.first(:name => name.to_s)
    value = computation.calculate(values)
    save_computes(name, value)
  end
  
  # @param [String] name
  # @return [Float]
  def constant(name)
    constant = GlobalConstant.first(:name => name.to_s)
    constant.value if constant
  end
  
  private
  # == Adds the computation values when a compute has been added
  # therefore external api users will know how something was calculated!
  # @param [Symbol] name
  # @param [Float] value
  # @return [Float] the value that you gave
  def save_computes(name, value)
    @calculating_answer.used_global_computations.merge!({name => value})
    value
  end
end
