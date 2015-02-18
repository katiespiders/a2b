class OTPTrip < Trip

	def directions(legs)
		dir_array = []
		legs.each_with_index do |leg, i|
			leg_obj = i > 0 ? Leg.new(leg, dir_array[i-1]) : Leg.new(leg)
			dir_array << leg_obj
		end

		dir_array
		# rtn_array = []
		# dir_array.each_with_index do |dir, i|
		# 	dir.prev_leg = i > 0 ? dir_array[i-1] : nil
		# 	# dir.next_leg = dir_array[i+1]
		# 	rtn_array << dir
		# end
		# rtn_array.each { |e| puts e.prev_leg, e.next_leg }
		# rtn_array
	end

	def summary(legs)
		walk_time, transit_time = 0, 0
		first_walk, last_walk, first_transit, last_transit = nil, nil, nil, nil

		legs.each do |leg|
			puts leg.mode, leg.route
			if leg.mode == 'WALK'
				first_walk ||= leg
				last_walk = leg
				walk_time += leg.duration
			else
				first_transit ||= leg
				last_transit = leg
				transit_time += leg.duration
			end
		end

		puts "first bus #{first_transit.start_time} to #{first_transit.end_time}"
		puts "last bus #{last_transit.start_time} to #{last_transit.end_time}"
		trip_ends = first_walk.duration + last_walk.duration
		trip_middle = last_transit.end_time - first_transit.start_time
		walk_middle = walk_time - trip_ends
		puts "walk ends #{trip_ends}, trip middle #{trip_middle}, walk middle #{walk_middle}"
		wait_time = trip_middle - transit_time - walk_middle
		arrival_time = last_transit.end_time + legs.last.duration
		trip_time = arrival_time - Time.now.to_i

		h = {
			walk_time: walk_time,
			transit_time: transit_time,
			wait_time: wait_time,
			trip_time: trip_time,
			arrival_time: Time.at(arrival_time).strftime("%-I:%M %P")
		}

		puts h
		h
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
