class Itinerary < TransitTrip
  attr_accessor :legs

  def initialize(itin)
    @xfers =          itin['transfers']
    @fare =           itin['fare']['fare']['regular']['cents'] if itin['fare']
    @legs =           directions(itin['legs'])
  end
end
