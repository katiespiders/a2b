class OTPTrip < Trip

	def directions(legs)
		dir_array = []
		first_transit_found = false
		xfer = false

		legs.each_with_index do |leg, i|
			unless leg['mode'] == 'WALK'
				xfer = first_transit_found
				first_transit_found = true
			end

			start_time = i == 0 ? Time.now.to_i + 5.minutes : dir_array[i-1].end_time
			Rails.logger.info "#{leg['mode']} leg #{i} starts at #{Time.at(start_time)}"

			dir_array << Leg.new(leg, start_time, xfer: xfer)
		end
		dir_array
	end

	def summary(legs)
		walk_time, transit_time = 0, 0
		first_walk, last_walk, first_transit, last_transit = nil, nil, nil, nil

		legs.each do |leg|
			Rails.logger.info leg.mode, leg.route
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

		Rails.logger.info "first bus #{first_transit.start_time} to #{first_transit.end_time}"
		Rails.logger.info "last bus #{last_transit.start_time} to #{last_transit.end_time}"
		trip_ends = first_walk.duration + last_walk.duration
		trip_middle = last_transit.end_time - first_transit.start_time
		walk_middle = walk_time - trip_ends
		Rails.logger.info "walk ends #{trip_ends}, trip middle #{trip_middle}, walk middle #{walk_middle}"
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

		Rails.logger.info h
		h
	end

	def routes(origin, destination)
		time = Time.now
		url = Rails.env.production? ? 'http://otp.seattle-a2b.com:8080/' : 'http://localhost:8080/'
		url += "otp/routers/default/plan?fromPlace=#{origin}&toPlace=#{destination}"
		Rails.logger.info "0 s: finding transit routes"
		rts = HTTParty.get(url)['plan']
		Rails.logger.info "#{Time.now - time} s: done with transit routes"
		rts
	end
end
