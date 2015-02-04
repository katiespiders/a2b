require 'httparty'
require 'latitude'

class Trip
  include Mongoid::Document

  field :start_time, type: Time
  field :end_time, type: Time
  field :mode, type: String # CAR, WALK, TRANSIT
	field :cost, type: Integer # transit fare or approx. car2go cost
	field :directions, type: Array # of street_legs and transit_legs
	field :origin, type: Array #[latitude, longitude]
	field :destination, type: Array #[latitude, longitude]

	def initialize(mode, origin, destination)
		@mode = mode
		@origin = origin
		@destination = destination
		set_routes
	end

	def set_routes
		case @mode
		when 'TRANSIT'
			@routes = transit_routes(routes)
		when 'CAR'
			@routes = car_routes(cars_available)
		when 'WALK'
		end
	end

	private
		def transit_routes(plan)
			{ from: plan['from']['name'],
		 		to: plan['to']['name'],
				itineraries: transit_itineraries(plan['itineraries'])
			}
		end

		def transit_itineraries(itin_array)
			return_array = []
			itin_array.each do |itin|
				return_array << {
					start_time: itin['startTime'],
					end_time: itin['endTime'],
					walk_time: itin['walkTime'],
					transit_time: itin['transitTime'],
					wait_time: itin['wait_time'],
					walk_distance: itin['walk_distance'],
					xfers: itin['transfers'],
					fare: itin['fare']['fare']['regular']['cents'],
					legs: directions(itin['legs'])
				}
			end
			return_array
		end
		
		def directions(legs)
			dir_array = []
			legs.each do |leg|
				if leg['mode'] == 'WALK'
					l = StreetLeg.new(
						mode: 'WALK', 
						start_time: leg['startTime']/1000, 
						end_time: leg['endTime']/1000)
					leg['steps'].each do |step|
						l.turns << Turn.new(
							street: step['streetName'],
							abs_direction: step['absoluteDirection'],
							rel_direction: step['relativeDirection'],
							distance: step['distance']
							)
					end
					dir_array << l
					
				else
					l = TransitLeg.new(
						mode: leg['mode'], 
						route: leg['route'], 
						headsign: leg['headsign'], 
						continuation?: leg['interlineWithPreviousLeg'],
						express?: leg['tripShortName'] == 'EXPRESS')
					l.stops << Stop.new(
						name: leg['from']['name'],
						stop_id: leg['from']['stopId']['id'],
						scheduled: leg['from']['departure']/1000,
						actual: leg['from']['departure']/1000)
					l.stops << Stop.new(
						name: leg['to']['name'],
						stop_id: leg['to']['stopId']['id'],
						scheduled: leg['to']['arrival']/1000,
						actual: leg['to']['arrival']/1000)
					dir_array << l
				end
			end
			dir_array
		end

		def routes(mode=@mode, origin=@origin, destination=@destination)
			origin = origin.join(',')
			destination = destination.join(',')
			url = Rails.env.development? ? "http://localhost:8080/" : "http://api.seattle-a2b.com/"
			url += "otp/routers/default/plan?fromPlace="

			case mode
			when 'TRANSIT'
				url += "#{origin}&toPlace=#{destination}"
			when 'CAR'
				url += "#{origin}&toPlace=#{@destination.join(',')}"
			when 'WALK'
				url += "#{@origin.join(',')}&toPlace=#{destination}"	
			end

			HTTParty.get(url)['plan']
		end	

		### CARS 

		def car_routes(cars)
			return_array = []
			cars.each do |car|
				coordinates = car_coords(car)
				return_array << {
					address: car['address'],
					coordinates: coordinates,
					exterior: car['exterior'] == 'GOOD',
					interior: car['interior'] == 'GOOD',
					gas: car['fuel'],
					name: car['name'],
					itinerary: car_itinerary(coordinates)
					}
			end
			return_array
		end

		# this is not going to work, but you know what I mean
		def car_itinerary(coordinates)
			{
				walk: HTTParty.get(routes_url('WALK', @origin, coordinates)),
		 		drive: HTTParty.get(routes_url('CAR'), coordinates, @destination)
			}
		end

		def cars
			cars_nearby = []
			cars_available.each do |car|
				car_coords = car_coords(car) # wtf is this line doing?
				car[:distance] = distance(car)
				cars_nearby << car if car[:distance] < 1.6
			end
			cars_nearby.sort_by { |car| car[:distance]}
		end
	
		def cars_available
			HTTParty.get(cars_url)['placemarks']
		end
		
		def cars_url
			"https://www.car2go.com/api/v2.1/vehicles?loc=seattle&oauth_consumer_key=#{ENV['CAR2GO_KEY']}&format=json"
		end

		def car_coords(car)
			[car['coordinates'][1], car['coordinates'][0]]
		end

		def distance(car) # in kilometers
			coords = car_coords(car)
			Latitude.great_circle_distance(@origin[0], @origin[1], coords[0], coords[1])
		end
end
