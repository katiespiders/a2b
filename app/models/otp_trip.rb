class OTPTrip < Trip

	def directions(legs)
		dir_array = []
		legs.each do |leg|
			if leg['mode'] == 'WALK'
        dir_array << StreetLeg.new(leg, 'otp')
			else
        dir_array << TransitLeg.new(leg)
			end
		end
		dir_array
	end

  def routes(origin, destination) # expects origin and destination as Location objects
    url = Rails.env.production? ? 'http://otp.seattle-a2b.com/' : 'http://localhost:8080/'
    url += "otp/routers/default/plan?fromPlace=#{origin.to_s}&toPlace=#{destination.to_s}"
    HTTParty.get(url)['plan']
  end
end
