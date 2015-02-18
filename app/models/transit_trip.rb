class TransitTrip < OTPTrip
	attr_accessor :trip

	def initialize(origin, destination)
    plan = routes(origin, destination)
		itineraries(plan['itineraries'][0])
	end

	def itineraries(itin) # all itineraries returned by OTP
		time = Time.now
		puts "0 s: building transit itinerary"
		@trip = Itinerary.new(itin)
		puts "#{Time.now - time} s: done with transit itineraries"
	end
end
