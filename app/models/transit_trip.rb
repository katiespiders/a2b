require 'trip'

class TransitTrip < Trip

	def initialize(origin, destination)
    @plan = otp_routes('TRANSIT', origin, destination)
	end

	def routes
		{ from:        @plan['from']['name'], # start location according to OTP
			to:          @plan['to']['name'], # end location according to OTP
			itineraries: itineraries(@plan['itineraries']) }
	end

	def itineraries(itins_array) # all itineraries returned by OTP
		trips_array = []
		itins_array.each { |itin| trips_array << itin_hash(itin) }
		trips_array
	end

	def itin_hash(itin)
		{	start_time:     itin['startTime'],
			end_time:       itin['endTime'],
			walk_time:      itin['walkTime'],
			transit_time:   itin['transitTime'],
			wait_time:      itin['wait_time'],
			walk_distance:  itin['walk_distance'],
			xfers:          itin['transfers'],
			fare:           itin['fare']['fare']['regular']['cents'],
			directions:     directions(itin['legs'])
    }
	end
end
