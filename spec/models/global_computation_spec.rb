require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "GlobalComputation" do
  describe "When computation are setup" do
    before(:each) do
      @kms_per_mile = GlobalConstant.create!(:name => :kms_per_mile, :value => 1.609)
      @earth_radius_in_miles = GlobalConstant.create!(:name => :earth_radius_in_miles, :value => 3963.19)
      
      @earth_radius_in_kms = GlobalComputation.create!(
        :name => "earth_radius_in_kms", 
        :paramters => [],
        :equation => "constant(:earth_radius_in_miles)*constant(:kms_per_mile)"
      )
      
      @deg2rad = GlobalComputation.create!(
        :name => "deg2rad", 
        :paramters => ["degress"],
        :equation => "value(:degress) / 180.0 * Math::PI"
      )
      
      @haversine_distance = GlobalComputation.create!(
        :name => "haversine_distance_degrees", 
        :paramters => ["lat1", "lng1", "lat2", "lng2"],
        :equation => %Q(
          compute(:earth_radius_in_kms) * 
          Math.acos(Math.sin(compute(:deg2rad, {:degress => value(:lat1)})) * Math.sin(compute(:deg2rad, {:degress => value(:lng2)}))) +
          Math.cos(compute(:deg2rad, {:degress => value(:lat1)})) * Math.cos(compute(:deg2rad, {:degress => value(:lat2)})) *
          Math.cos(compute(:deg2rad, {:degress => value(:lng2)}) - compute(:deg2rad, {:degress => value(:lng1)}))
      ))
    end
    
    
    describe "Deg2Rad#calculate", "Given we give it 1 Degrees"do
      it "should be 0.0174532925 radiens" do
        @deg2rad.calculate(:degress => 1).round(10).should == 0.0174532925
      end
    end
    
    describe "earth_radius_in_kms#calculate" do
      it "should be 0.0174532925 radiens" do
        @earth_radius_in_kms.calculate.round(10).should == 6376.77271
      end
    end
    
    describe "haversine_distance#calculate" do
      it "should be 0.0174532925 km" do
        @haversine_distance.calculate(:lat1 => 0.343, :lng1 => 0.343, :lat2 => 0.343, :lng2 => 0.343).round(10).should == 10017.3825862016
      end
    end
    
  end
end



#           
# class Haversine
#   KMS_PER_MILE = 1.609
#   EARTH_RADIUS_IN_MILES = 3963.19
#   EARTH_RADIUS_IN_KMS = EARTH_RADIUS_IN_MILES * KMS_PER_MILE
#   
#   def self.distance_between(from, to)
#     EARTH_RADIUS_IN_KMS * 
#       Math.acos( Math.sin(deg2rad(from.latitude)) * Math.sin(deg2rad(to.latitude)) + 
#       Math.cos(deg2rad(from.latitude)) * Math.cos(deg2rad(to.latitude)) * 
#       Math.cos(deg2rad(to.longitude) - deg2rad(from.longitude)))  
#   end
# 
#   def self.deg2rad(degrees)
#     degrees.to_f / 180.0 * Math::PI
#   end
# end