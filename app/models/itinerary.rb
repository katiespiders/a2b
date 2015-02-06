class Itinerary < Trip
  attr_accessor :route

  def initialize(itin)
  	@start_time =     itin['startTime']
    @end_time =       itin['endTime']
    @walk_time =      itin['walkTime']
    @transit_time =   itin['transitTime']
    @wait_time =      itin['wait_time']
    @walk_distance =  itin['walk_distance']
    @xfers =          itin['transfers']
    @fare =           itin['fare']['fare']['regular']['cents']
    @route =          directions(itin['legs'])
  end
end
