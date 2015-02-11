require 'otp_trip'

class TransitTrip < OTPTrip
	attr_accessor :route

	def initialize(origin, destination)
    @plan = routes(geocode(origin), geocode(destination))
		@route = routes_hash
	end

	def routes_hash
		{
			from: @plan['from']['name'],
			to: @plan['to']['name'],
			directions: itineraries(@plan['itineraries'])
		}
	end

	def itineraries(itins_array) # all itineraries returned by OTP
		trips_array = []
		itins_array.each { |itin| trips_array << Itinerary.new(itin) }
		trips_array
	end
end
