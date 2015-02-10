require 'httparty'
require 'latitude'
require 'location'

class Trip

	def otp_directions(legs)
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

	def google_directions(legs, mode)
		dir_array = []
		legs.each do |leg|
			l = StreetLeg.new(leg, 'google')
			l.mode = mode
			dir_array << l
		end
		dir_array
	end

  def otp_routes(mode, origin, destination)
    url = Rails.env.production? ? 'http://otp.seattle-a2b.com/' : 'http://localhost:8080/'
    url += "otp/routers/default/plan?fromPlace=#{origin.to_s}&toPlace=#{destination.to_s}"
    url += "&mode=#{mode}" unless mode == 'TRANSIT'
    HTTParty.get(url)['plan']
  end

  def google_routes(mode, origin, destination)
    url = 'https://maps.googleapis.com/maps/api/directions/json?'
    url += "origin=#{origin.to_s}&destination=#{destination.to_s}&mode=#{mode}"
    url += "&key=#{ENV['GOOGLE_KEY']}"
    HTTParty.get(url)['routes']
  end

  def geocode(address)
    results = HTTParty.get(geocode_url(address))['results']
		coords = results[0]['geometry']['location']
		Location.new(coords['lat'], coords['lng'])
  end

	def geocode_url(address)
		"https://maps.googleapis.com/maps/api/geocode/json?address=#{address.gsub(' ', '+')}"
	end
end
