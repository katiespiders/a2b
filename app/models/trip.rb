class Trip
	attr_accessor :legs, :summary

	def initialize(origin, destination) # lat,lng strings
		routes = routes(origin, destination)
		itinerary(routes[0])
	end

	private
		def itinerary(itin)
			time = Time.now
			Rails.logger.info "0 s: building transit itinerary"

			@xfers = itin['transfers']
			@fare = itin['fare'] ? itin['fare']['fare']['regular']['cents'] : nil
			@legs = directions(itin['legs'])
			@summary = summarize(@legs)

			Rails.logger.info "#{Time.now - time} s: done with transit itineraries"
		end

		def directions(legs)
			dir_array = []
			first_transit_found = false
			xfer = false

			legs.each_with_index do |leg, i|
				unless leg['mode'] == 'WALK'
					xfer = first_transit_found
					first_transit_found = true
				end # flag all transit legs after the first as transfers

				start_time = i == 0 ? Time.now.to_i + 5.minutes : dir_array[i-1].end_time
				Rails.logger.info "leg #{i} (#{leg['mode']}) starts at #{Time.at(start_time).strftime("%-I:%M %P")}"

				dir_array << Leg.new(leg, start_time, xfer: xfer)
			end
			dir_array
		end

		def summarize(legs)
			walk_time, transit_time, wait_time = 0, 0, 0

			legs.each_with_index do |leg, i|
				leg.mode == 'WALK' ? walk_time += leg.duration : transit_time += leg.duration
				wait_time += (leg.start_time - legs[i-1].end_time) if i > 0
			end

			arrival_time = legs.last.end_time
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
			rts = HTTParty.get(url)['plan']['itineraries']
			Rails.logger.info "#{Time.now - time} s: done with transit routes"
			rts
		end
end
