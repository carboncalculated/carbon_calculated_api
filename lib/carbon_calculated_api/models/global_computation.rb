class GlobalComputation
  include MongoMapper::Document
  include CarbonCalculatedApi::Model

  # keys
  # key :name, String, :unique => true, :required => true
  # key :parameters, Set, :required => true
  # key :equation, String
  
  # instance eval on the equation string you can
  # @example
  #   constant(:earth_radius_in_miles)*constant(:kms_per_mile)
  # @example
  #    value(:degress) / 180.0 * Math::PI
  # @example
  #   computation(:earth_radius_in_kms) * 
  #   Math.acos(Math.sin(computation(:deg2rad, {:degress => value(:lat1)})) * Math.sin(computation(:deg2rad, {:degress => value(:lng2)}))) +
  #   Math.cos(computation(:deg2rad, {:degress => value(:lat1)})) * Math.cos(computation(:deg2rad, {:degress => value(:lat2)})) *
  #   Math.cos(computation(:deg2rad, {:degress => value(:lng2)}) - computation(:deg2rad, {:degress => value(:lng1)}))
  #
  def calculate(answers = {})
    @answers = answers.with_indifferent_access
    instance_eval(self.equation)
  end

  def value(name)
    @answers[name]
  end
  
  
  # @return [Float]
  #
  # @param [Symbol, #to_s] name
  # @param [Hash] values
  def compute(name, values = {})
    computation = GlobalComputation.first(:name => name.to_s)
    computation.calculate(values) if computation
  end
  
  
  # @return [Float]
  #
  # @param [String] name
  def constant(name)
    constant = GlobalConstant.first(:name => name.to_s)
    constant.value if constant
  end
end