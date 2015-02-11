class CarTrip < GoogleTrip
  attr_accessor :trip

  def initialize(origin, destination)
    time = Time.now
    puts "geocoding car trip from #{origin} to #{destination}"
    @origin = geocode(origin)
    @destination = geocode(destination)
    puts "#{Time.now - time} s: finding nearest car"
    @car = cars_nearby[0]
    puts "#{Time.now - time} s: finding directions for car"
    @trip = set_route
    puts "#{Time.now - time} s: done with car trip"
  end

	def set_route
		cars = car_hash(@car)
		cars[:itinerary] = itinerary(coords(@car))
		cars
	end

  private
    def cars_nearby
      cars_nearby = []
      cars_available.each do |car|
        car['distance'] = distance(coords(car))
        cars_nearby << car if car['distance'] < 1.6
      end
      cars_nearby.sort_by { |car| car['distance'] }
    end

    def cars_available
      HTTParty.get(url)['placemarks']
    end

    def url
      "https://www.car2go.com/api/v2.1/vehicles?loc=seattle&oauth_consumer_key=#{ENV['CAR2GO_KEY']}&format=json"
    end

    def coords(car)
      Location.new(car['coordinates'][1], car['coordinates'][0])
    end

    def distance(coords) # in kilometers
      Latitude.great_circle_distance(@origin.lat, @origin.long, coords.lat, coords.long)
    end

    def itinerary(coordinates)
      walk = routes('walking', @origin.to_s, coordinates.to_s)[0]['legs']
      drive = routes('driving', coordinates.to_s, @destination.to_s)[0]['legs']

      walk_directions = directions(walk, 'WALK')
      drive_directions = directions(drive, 'CAR')

      [walk_directions, drive_directions]
    end

  	def car_hash(car)
  		{ address: 			car['address'],
  			coordinates:	coords(car),
  	 		exterior: 		car['exterior'] == 'GOOD',
  			interior: 		car['interior'] == 'GOOD',
  			gas: 					car['fuel'],
  			name: 				car['name']	}
  	end

end
