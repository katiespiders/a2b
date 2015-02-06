class TransitTrip < Trip

	def initialize(plan)
		@plan = plan
	end

	def routes
		{ from:        @plan['from']['name'], # start location according to OTP
			to:          @plan['to']['name'], # end location according to OTP
			itineraries: transit_itineraries(@plan['itineraries']) }
	end

	def transit_itineraries(itin_array) # all itineraries returned by OTP
		transit_trip_array = []
		itin_array.each { |itin| transit_trip_array << transit_itin_hash(itin) }
		transit_trip_array
	end

	def transit_itin_hash(itin)
		{	start_time:     itin['startTime'],
			end_time:       itin['endTime'],
			walk_time:      itin['walkTime'],
			transit_time:   itin['transitTime'],
			wait_time:      itin['wait_time'],
			walk_distance:  itin['walk_distance'],
			xfers:          itin['transfers'],
			fare:           itin['fare']['fare']['regular']['cents'],
			directions:     directions(itin['legs']) }
	end
end
