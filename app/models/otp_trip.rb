class OTPTrip < Trip

	def directions(legs)
		dir_array = []
		legs.each_with_index do |leg, i|
			nxt = if i == legs.length - 1
				nil
			else
				make_leg(legs[i+1], i)
			end
			dir_array << make_leg(leg, i, nxt)
		end
		dir_array.reject { |leg| !leg }
	end

	def make_leg(leg, i, nxt=nil)
		if leg['mode'] == 'WALK'
			# StreetLeg.new(leg, 'otp', nxt)
		else
			puts leg
			TransitLeg.new(leg, nxt)
		end
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
