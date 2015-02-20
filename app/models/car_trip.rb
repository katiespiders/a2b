class CarTrip
  attr_accessor :car

  def initialize(origin)
    @origin = origin
    time = Time.now
    Rails.logger.error "0 s: finding nearest car"
    @car = car_hash(cars_nearby[0])
    Rails.logger.error "#{Time.now - time} s: found car"
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
      [car['coordinates'][1], car['coordinates'][0]]
    end

    def distance(coords) # in kilometers
      origin = @origin.split(',')
      Latitude.great_circle_distance(origin[0], origin[1], coords[0], coords[1])
    end

  	def car_hash(car)
  		{ address: 			address_str(car['address']),
        coordinates:  coords(car),
  	 		exterior: 		car['exterior'] == 'GOOD',
  			interior: 		car['interior'] == 'GOOD',
  			gas: 					car['fuel'],
  			name: 				car['name']
      } if car
  	end

    def address_str(address)
      street = /^(.*),/.match(address)[1]
      split = street.index /(\s|\d)*$/
      if split < street.length
        "#{street[split..-1]} #{street[0...split]}"
      else
        street
      end
    end
end
