class CarTrip < GoogleTrip
  attr_accessor :trip

  def initialize(origin, destination)
    time = Time.now
    puts "0 s: geocoding car trip from #{origin} to #{destination}"
    @origin = geocode(origin)
    @destination = geocode(destination)
    puts "#{Time.now - time} s: finding nearest car"
    @car = cars_nearby[0]
    puts "#{Time.now - time} s: finding directions for car"
    @trip = set_route
    puts "#{Time.now - time} s: done with car trip"
  end

	def set_route
    if @car
  		cars = car_hash(@car)
  		cars[:itinerary] = itinerary(coords(@car))
  		cars
    end
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

      {walk: walk_directions, drive: drive_directions}
    end

  	def car_hash(car)
  		{ address: 			address_str(car['address']),
  	 		exterior: 		car['exterior'] == 'GOOD',
  			interior: 		car['interior'] == 'GOOD',
  			gas: 					car['fuel'],
  			name: 				car['name']	}
  	end

    def address_str(address)
      puts "!"*80, address
      street = /^(.*),/.match(address)[1]
      split = street.index /(\s|\d)*$/
      puts "@"*80, "split string of length #{street.length} at #{split}"
      if split < street.length
        "#{street[split..-1]} #{street[0...split]}"
      else
        street
      end
    end

end
