class Itinerary < TransitTrip
  attr_accessor :legs

  def initialize(itin)
  	@start_time =     itin['startTime'] / 1000
    @end_time =       itin['endTime'] / 1000
    @duration =       @end_time - @start_time
    @walk_time =      itin['walkTime']
    @transit_time =   itin['transitTime']
    @wait_time =      itin['waitingTime']
    @walk_distance =  itin['walkDistance']
    @xfers =          itin['transfers']
    @fare =           itin['fare']['fare']['regular']['cents'] if itin['fare']
    @legs =           directions(itin['legs'])
  end
end
