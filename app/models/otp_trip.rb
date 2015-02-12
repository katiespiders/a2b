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
		dir_array
	end

	def make_leg(leg, i, nxt=nil)
		if leg['mode'] == 'WALK'
			StreetLeg.new(leg, 'otp', nxt)
		else
			TransitLeg.new(leg, nxt)
		end
	end

	def html_instructions(legs)
		instr = ''
		legs.each { |leg| instr += "#{leg.instructions} " }
		instr
	end

  def routes(origin, destination) # expects origin and destination as Location objects
		time = Time.now
    url = Rails.env.production? ? 'http://otp.seattle-a2b.com/' : 'http://localhost:8080/'
    url += "otp/routers/default/plan?fromPlace=#{origin.to_s}&toPlace=#{destination.to_s}"
		puts "0 s: finding transit routes"
    rts = HTTParty.get(url)['plan']
		puts "#{Time.now - time} s: done with transit routes"
		rts

  end
end
