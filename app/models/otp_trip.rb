class OTPTrip < Trip

	def directions(legs)
		dir_array = []
		legs.each_with_index do |leg, i|
			if leg['mode'] == 'WALK'
				dir_array << {
					mode: 'WALK',
					from: [leg['from']['lat'], leg['from']['lon']],
					to: [leg['to']['lat'], leg['to']['lon']],
					next_mode: next_mode(legs, i)
				}
			else
				dir_array << TransitLeg.new(leg, next_mode(legs, i))
			end
		end
		dir_array
	end

	def next_mode(legs, i)
		legs[i+1] ? legs[i+1]['mode'] : nil
	end

  def routes(origin, destination)
		time = Time.now
    url = Rails.env.production? ? 'http://otp.seattle-a2b.com/' : 'http://localhost:8080/'
    url += "otp/routers/default/plan?fromPlace=#{origin}&toPlace=#{destination}"
		puts "0 s: finding transit routes"
    rts = HTTParty.get(url)['plan']
		puts "#{Time.now - time} s: done with transit routes"
		rts
  end
end
