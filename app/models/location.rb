class Location
  attr_accessor :lat, :long
  
  def initialize(lat, long)
    @lat = lat
    @long = long
  end

  def to_s
    "#{@lat},#{@long}"
  end
end
