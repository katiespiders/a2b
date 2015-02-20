class TransitTrip < OTPTrip
	attr_accessor :trip

	def initialize(origin, destination)
    plan = routes(origin, destination)
		itineraries(plan['itineraries'][0])
	end

	def itineraries(itin) # all itineraries returned by OTP
		time = Time.now
		Rails.logger.error "0 s: building transit itinerary"
		@trip = Itinerary.new(itin)
		Rails.logger.error "#{Time.now - time} s: done with transit itineraries"
	end
end
