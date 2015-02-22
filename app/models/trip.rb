class Trip
	attr_accessor :best

	def initialize(origin, destination) # lat,lng strings
		itineraries = []
		routes = routes(origin, destination) # calls Open Trip Planner API
		routes.each { |route| itineraries << itinerary(route) }
		@best = itineraries[0]
		itineraries.each do |itin|
			itin_time = itin[:summary][:trip_time]
			@best = itin if itin_time < @best[:summary][:trip_time]
		end
	end

	private
		def itinerary(itin)
			time = Time.now
			Rails.logger.info "*"*80
			Rails.logger.info "0 s: building transit itinerary"

			hsh = {
				xfers: itin['transfers'],
				fare: itin['fare'] ? itin['fare']['fare']['regular']['cents'] : nil,
				legs: directions(itin['legs'])
			}
			hsh[:summary] = summarize(hsh[:legs])

			Rails.logger.info "#{Time.now - time} s: done with transit itinerary"
			hsh
		end

		def directions(legs)
			dir_array = []
			first_transit_found = false
			xfer = false

			legs.each_with_index do |leg, i|
				unless leg['mode'] == 'WALK'
					first_transit_index ||= i
					xfer = first_transit_found
					first_transit_found = true
				end # flag all transit legs after the first as transfers, and save index of first transit leg

				start_time = i == 0 ? Time.now.to_i + 5.minutes : dir_array[i-1].end_time
				Rails.logger.info "leg #{i} (#{leg['mode']}) starts at #{Time.at(start_time).strftime("%-I:%M %P")}"

				dir_array << Leg.new(leg, start_time, xfer, i == first_transit_index)
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

			hsh = {
				walk_time: walk_time,
				transit_time: transit_time,
				wait_time: wait_time,
				trip_time: trip_time,
				arrival_time: Time.at(arrival_time).strftime("%-I:%M %P")
			}

			Rails.logger.info hsh
			hsh
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
