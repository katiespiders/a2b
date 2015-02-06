require 'httparty'
require 'latitude'

class Trip

  def otp_routes(mode, origin, destination)
    origin = origin.join(',')
    destination = destination.join(',')
    url = Rails.env.production? ? "http://otp.seattle-a2b.com/" : "http://localhost:8080/"
    url += "otp/routers/default/plan?fromPlace=#origin}&toPlace=#destination}"
    url += "&mode=#mode}" unless mode == 'TRANSIT'

    HTTParty.get(url)['plan']
  end

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
end
