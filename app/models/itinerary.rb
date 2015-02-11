class Itinerary < OTPTrip
  attr_accessor :trips

  def initialize(itin)
  	@start_time =     itin['startTime']
    @end_time =       itin['endTime']
    @walk_time =      itin['walkTime']
    @transit_time =   itin['transitTime']
    @wait_time =      itin['waitingTime']
    @walk_distance =  itin['walkDistance']
    @xfers =          itin['transfers']
    @fare =           itin['fare']['fare']['regular']['cents'] if itin['fare']
    @trips =          directions(itin['legs'])
  end
end
