class Computation
  include MongoMapper::Document
  include CarbonCalculatedApi::Model
  
  # == keys
  key :name, String
  key :calculator_id, ObjectId
  key :description, String
  key :active_at, Time
  key :position, Integer, :default => 1
  timestamps!
  
  # == Attrs
  attr_accessor :calculation_time
  
  # == Associations
  many :answer_sets
  
  private
  def answer_set_for_calculation_time
    if @calculation_time 
      active_answer_sets.first(:active_at.lt => @calculation_time, :order => :active_at.desc)
    else
      active_answer_sets.first(:order => :active_at.desc)
    end
  end
  
  # We method miss the computation to the answer set for the
  # calculation time; allowing for versioning of formulas
  def method_missing(method, *args, &block)
    
    if args && args[0] && args[0].is_a?(Hash)
      args[0].with_indifferent_access
    end
    
    @answer_set ||= answer_set_for_calculation_time
    raise Calculator::NoCalculationExistsError, "No answer available" unless @answer_set
    if @answer_set.respond_to?(method)
      @answer_set.send(method, *args, &block)
    else
      super
    end
  end

end
