class OTPTrip < Trip

	def directions(legs)
		dir_array = []
		legs.each { |leg| dir_array << Leg.new(leg) }

		rtn_array = []
		dir_array.each_with_index do |dir, i|
			dir.prev_leg = i > 0 ? dir_array[i-1] : nil
			# dir.next_leg = dir_array[i+1]
			rtn_array << dir
		end
		rtn_array.each { |e| puts e.prev_leg, e.next_leg }
		rtn_array
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
