class Trip
	attr_accessor :best

	def initialize(origin, destination)
		itineraries = []
		routes = otp_routes(origin, destination)
		routes.each { |route| itineraries << itinerary(route) }
		best_itinerary(itineraries)
	end

	private
		def otp_routes(origin, destination)
			time = Time.now
			url = Rails.env.production? ? 'http://otp.seattle-a2b.com' : 'http://localhost'
			url += ":8080/otp/routers/default/plan?fromPlace=#{origin}&toPlace=#{destination}"

			Rails.logger.info "0 s: finding transit routes"
			routes = HTTParty.get(url)['plan']['itineraries']
			Rails.logger.info "#{Time.now - time} s: done with transit routes"
			routes
		end

		def itinerary(route)
			time = Time.now
			Rails.logger.info "*"*80
			Rails.logger.info "0 s: building transit itinerary"

			hsh = {
				xfers: route['transfers'],
				fare: route['fare'] ? route['fare']['fare']['regular']['cents'] : nil,
				legs: directions(route['legs'])
			}
			hsh[:summary] = summarize(hsh[:legs])

			Rails.logger.info "#{Time.now - time} s: done with transit itinerary"
			hsh
		end

		def directions(legs)
			dir_array = []
			xfer = false
			first_transit_index = nil

			legs.each_with_index do |leg_hash, i|
				first_transit_index ||= i unless leg_hash['mode'] == 'WALK'
				Rails.logger.info "index #{i}, dir_array length #{dir_array.length}"
				start_time = i == 0 ? Time.now.to_i + 5.minutes : dir_array[i-1].end_time
				Rails.logger.debug "leg #{i} (#{leg_hash['mode']}) starts at #{Time.at(start_time).strftime("%-I:%M %P")}"

				next_leg_hash = legs[i+1] if i<legs.length-1

				dir_array << Leg.new(leg_hash, next_leg_hash, i == first_transit_index, start_time) unless leg_hash['interlineWithPreviousLeg']
				last = dir_array.last
				Rails.logger.info "added #{last}"
				Rails.logger.info "a #{last.class}"
				Rails.logger.info "ending at #{last.end_time}"
				end
			dir_array
		end

		def best_itinerary(itins)
			@best = itins[0]
			itins.each do |itin|
				itin_time = itin[:summary][:trip_time]
				@best = itin if itin_time < @best[:summary][:trip_time]
			end
		end

		def summarize(legs)
			walk_time, transit_time, wait_time = 0, 0, 0

			legs.each_with_index do |leg, i|
				leg.mode == 'WALK' ? walk_time += leg.duration : transit_time += leg.duration
				wait_time += (leg.start_time - legs[i-1].end_time) if i > 0 # potential bugs here ????? whence the -64028 wait times?
			end

			arrival_time = legs.last.end_time
			trip_time = arrival_time - Time.now.to_i

			hsh = {
				walk_time: walk_time,
				transit_time: transit_time,
				wait_time: wait_time,
				trip_time: trip_time,
				arrival_time: Time.at(arrival_time).strftime("%-I:%M %P")
			}

			Rails.logger.debug hsh
			hsh
		end
end
