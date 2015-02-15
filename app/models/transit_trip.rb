class TransitTrip < OTPTrip
	attr_accessor :trip, :instructions

	def initialize(origin, destination)
    @plan = routes(origin, destination)
		@trip = routes_hash
	end

	def routes_hash
		{
			from: @plan['from']['name'],
			to: @plan['to']['name'],
			directions: itineraries(@plan['itineraries'])
		}
	end

	def itineraries(itins_array) # all itineraries returned by OTP
		time = Time.now
		puts "0 s: building transit itineraries"
		trips_array = []
		itins_array.each { |itin| trips_array << Itinerary.new(itin) }
		puts "#{Time.now - time} s: done with transit itineraries"
		trips_array
	end
end
