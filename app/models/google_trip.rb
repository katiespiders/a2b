class GoogleTrip < Trip

	def directions(legs, mode)
		dir_array = []
		legs.each do |leg|
			l = StreetLeg.new(leg, 'google')
			l.mode = mode
			dir_array << l
		end
		dir_array
	end

  def routes(mode, origin, destination) # expects origin and destination as Location objects
    url = 'https://maps.googleapis.com/maps/api/directions/json?'
    url += "origin=#{origin.to_s}&destination=#{destination.to_s}&mode=#{mode}"
    url += "&key=#{ENV['GOOGLE_KEY']}"
    HTTParty.get(url)['routes']
  end
end
