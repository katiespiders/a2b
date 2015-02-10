require 'httparty'
require 'latitude'

class Trip

	def directions(legs) # array of trip legs, e.g. [walk, car] or [walk, bus, bus, walk]
		dir_array = []
		legs.each do |leg|
			if leg['mode'] == 'WALK' || leg['mode'] == 'CAR'
        dir_array << StreetLeg.new(leg)
			else
        dir_array << TransitLeg.new(leg)
			end
		end
		dir_array
	end

  def otp_routes(mode, origin, destination)
    origin = origin.join(',')
    destination = destination.join(',')
    url = Rails.env.production? ? 'http://otp.seattle-a2b.com/' : 'http://localhost:8080/'
    url += "otp/routers/default/plan?fromPlace=#{origin}&toPlace=#{destination}"
    url += "&mode=#{mode}" unless mode == 'TRANSIT'
    puts url
    HTTParty.get(url)['plan']
  end

  def google_routes(mode, origin, destination)
    # test url: https://maps.googleapis.com/maps/api/directions/json?origin=352%20N%2080th%20St,Seattle&destination=525%2021st%20Ave,Seattle&mode=transit&key=AIzaSyAgwByXWJd6S7oFF3XLdhRTcMvgu5Vj8q0
    url = 'https://maps.googleapis.com/maps/api/directions/json?'
    url += "origin=#{origin}&destination=#{destination}&mode=#{mode}"
    url += "&key=#{ENV['GOOGLE_KEY']}"
    HTTParty.get(url)
  end
end
