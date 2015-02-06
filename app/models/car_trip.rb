class CarTrip
  include Mongoid::Document

	def initialize(plan)
		@plan = plan
	end

	def car_route(car)
		{ address:      car['address'],
			coordinates:  coords(car),
			exterior:     car['exterior'] == 'GOOD',
			interior:     car['interior'] == 'GOOD',
			gas:          car['fuel'],
			name:         car['name'],
			itinerary:    car_itinerary(coords(car)) }
		end

	def car_itinerary(coordinates)
		walk = otp_routes('WALK', @origin, coordinates) # origin to car location
		drive = otp_routes('CAR', coordinates, @destination) #car location to destination

		return nil unless walk && drive # hack for OTP API bug

		walk_directions = directions(walk['itineraries'][0]['legs'])
		drive_directions = directions(drive['itineraries'][0]['legs'])

		{ from:       walk['from']['name'],
			to:         drive['to']['name'],
			directions: [walk_directions[0], drive_directions[0]] }
	end

	def cars_nearby
		cars_nearby = []
		cars_available.each do |car|
			car[:distance] = distance(coords(car))
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

	def coords(car)
		[car['coordinates'][1], car['coordinates'][0]]
	end

	def distance(coords) # in kilometers
		Latitude.great_circle_distance(@origin[0], @origin[1], coords[0], coords[1])
	end

end
