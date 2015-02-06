require 'trip'

class TransitTrip < Trip

	def initialize(origin, destination)
    @plan = otp_routes('TRANSIT', origin, destination)
	end

	def routes
		 from:        @plan['from']['name'], # start location according to OTP
			to:          @plan['to']['name'], # end location according to OTP
			itineraries: itineraries(@plan['itineraries']) }
	end

	def itineraries(itins_array) # all itineraries returned by OTP
		trips_array = []
		itins_array.each  |itin| trips_array << Itinerary.new(itin) }
		trips_array
	end
end
