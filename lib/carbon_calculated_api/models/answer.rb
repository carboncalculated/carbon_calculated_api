require "chronic"
class Answer

  # == Attrs
  attr_accessor :validations
  attr_accessor :answer_errors
  attr_accessor :object_references
  attr_accessor :used_global_computations
  
  def initialize(options = {})
    @answer_errors = {}
    @object_references = {}
    calculator_id = options[:calculator_id]
    computation_id = options[:computation_id]
    @calculation_time = options[:calculation_time]
    @answer = options[:answer] || {}
    clear_answer_of_empty_values!(@answer)
    @calculator = Calculator.find(calculator_id) if calculator_id
    @computation = Computation.find(computation_id) if computation_id
    raise Calculator::NoCalculationExistsError, "No calculator available" unless @calculator || @computation
    if @computation
      @computation.calculation_time = Chronic.parse(@calculation_time)
    end
  end
  
  def clear_answer_of_empty_values!(answer)
    answer.each_pair do |key, value|
      answer.delete(key) if value.to_s.empty?
    end
  end
  
  def apply_defaults_to_answer!
      @computation.answer_choices.each do |answer_choice|
      if default_value = (answer_choice.respond_to?(:default_value) && answer_choice.default_value)
        @answer = {answer_choice.name => default_value}.merge!(@answer)
      end
    end
    coerce_answer_values_for_float!
  end
  
  # == we need to coerce if can be integer let it be that 
  # otherwise float if not that then must be a string
  def coerce_answer_values_for_float!
    @answer.each_pair do |key, value|
      @answer[key] = Integer(value) rescue Float(value) rescue value
    end
  end
  
  def validations
    @validations ||= @computation.validations.flatten rescue []
  end

  # @return [Class]
  def build_validator
    usedable_validations = validations

    Class.new(::OpenStruct) do
      include ActiveModel::Validations
      extend ActiveModel::Naming

      def self.name
        "Answer"
      end
      
      # if the validation is a validator get its class
      # @params [Validation] validation
      def self.validation_validator(val)
        if val["has_validator"] == "true" || val["has_validator"] == true
          val["validator_class"].constantize
        else
          val["answer_field_name"].to_sym
        end
      end
  
      def self.evaled_validation_options(validation_options)
        new_options = {}
        validation_options.each_pair do |key, value|
          case key 
          when "name", "condition", "characteristic_attribute", "characteristic_value", "object_reference_name"
            new_options.merge!({key.to_sym => value})
          else
            new_options.merge!({key.to_sym => value.is_a?(String) ? eval(value) : value})
          end
        end
        new_options
      end
      
      usedable_validations.each do |validation|
        if !validation.options.empty?
          self.send(validation.name, validation_validator(validation), evaled_validation_options(validation.options))
        else
          self.send(validation.name, validation_validator(validation))       
        end        
      end
  
    end
  end

  # @return [OpenStruct]
  def validator
    @validator ||= build_validator.new(@answer)
  end
  
  # reset the answer errors
  # before finding a computation
  # we must apply the defaults so validations
  # are passed and formula are evaled successfully
  def valid?
    self.answer_errors = {}
    find_computation!
    apply_defaults_to_answer! if @computation
    validator.valid? && !@computation.nil?
  end

  # we delagate; to errors to the validator
  # if a computation exists; otherwise
  #
  # the errors generated from trying to find
  # a computation; are then sorted and intersected
  # to give the best possible determination of what 
  # the errors maybe; 
  def errors
    find_computation!
    if @computation
      validator.errors
    else
      
     # Errors should be merged ie intersection
     # if 2 have same amount intersect then
     # this should cover nearly all that we need 
     sorted_answer_errors = self.answer_errors.sort[0][1]
     all_errors = sorted_answer_errors.flatten
     intersected_keys = all_errors.map(&:keys).flatten!
     all_errors.each do |err|
       intersected_keys = intersected_keys & err.keys
     end
     combined_errors = all_errors.inject({}) {|var, hash| var.merge!(hash);var}
     found_errors = combined_errors.reject{|key,value| !intersected_keys.include?(key)}
     found_errors.empty? ? ["Please supply all the required values"] : found_errors
    end
  end
  
  
  # Find the computation is slightly intense; 
  # if we already have a computation then that
  # is just returned
  # otherwise we have to try to determine the computation
  # the first valid computation will be return
  # if none are found the errors are stored
  def find_computation!
    return @computation if @computation
    @computation = @calculator.computations.detect do |comp|
      answer = Answer.new(:answer => @answer, :computation_id => comp.id, :computation_time => @computation_time)
      valid = answer.valid?
      if !valid
        if self.answer_errors[answer.errors.size].nil?
          self.answer_errors[answer.errors.size] = [answer.errors]
        else
          self.answer_errors[answer.errors.size] << answer.errors
        end
      end
      valid
    end
  end
  
  # if the answer is valid we ask for the computation
  # each equations associated with the answer_set will 
  # be set in the values; object references and their
  # formula input are set via object references
  # we make sure that the object_reference it empty
  # before performing the calculation
  #
  # if the answer is not valid the errors are return
  # @return [Hash] values of calculation or errors
  def calculate
    if valid?
      @object_references = {}
      @used_global_computations = {}
      values = {:calculations => (@computation.calculate(self, @answer) || {})}
      values.merge!(:answer_set_id => @computation.answer_set_id.to_s, :source => @computation.answer_set_source, :calculator_id => @computation.calculator_id.to_s, :computation_id => @computation.id.to_s, :object_references => @object_references, :used_global_computations => @used_global_computations)
    else
      {:errors => errors}
    end
  end
end
