class TransitTrip < OTPTrip
	attr_accessor :trip, :instructions, :prev, :next

	def initialize(origin, destination)
    @plan = routes(origin, destination)
		@trip = routes_hash
	end

	def routes_hash
		{
			from: @plan['from']['name'],
			to: @plan['to']['name'],
			directions: itineraries(@plan['itineraries'][0])
		}
	end

	def itineraries(itin) # all itineraries returned by OTP
		time = Time.now
		puts "0 s: building transit itinerary"
		trip = Itinerary.new(itin)
		puts "#{Time.now - time} s: done with transit itineraries"
		return trip
	end
end
