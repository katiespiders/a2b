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
		@routes = set_routes
	end

  def routes
    @routes
  end

	private
    def set_routes
      case @mode
      when 'TRANSIT'
        transit_routes(otp_routes)
      when 'CAR'
        car_hash(cars_nearby[0])
      when 'WALK'
      end
    end

    ### TRANSIT
		def transit_routes(plan)
			{ from:        plan['from']['name'], # start location according to OTP
		 		to:          plan['to']['name'], # end location according to OTP
				itineraries: transit_itineraries(plan['itineraries']) }
		end

		def transit_itineraries(itin_array) # all itineraries returned by OTP
			transit_trip_array = []
			itin_array.each { |itin| transit_trip_array << transit_itin_hash(itin) }
			transit_trip_array
		end

		def transit_itin_hash(itin)
			{	start_time:     itin['startTime'],
				end_time:       itin['endTime'],
				walk_time:      itin['walkTime'],
				transit_time:   itin['transitTime'],
				wait_time:      itin['wait_time'],
				walk_distance:  itin['walk_distance'],
				xfers:          itin['transfers'],
				fare:           itin['fare']['fare']['regular']['cents'],
				directions:     directions(itin['legs']) }
		end

		### CARS
    def car_hash(car)
      { address:      car['address'],
        coordinates:  coords(car),
        exterior:     car['exterior'] == 'GOOD',
        interior:     car['interior'] == 'GOOD',
        gas:          car['fuel'],
        name:         car['name'],
        directions:   car_directions(coords(car)) }
      end

		def car_directions(coordinates)
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

		### OTP
    def otp_routes(mode=@mode, origin=@origin, destination=@destination)
      origin = origin.join(',')
      destination = destination.join(',')
      url = Rails.env.development? ? "http://localhost:8080/" : "http://api.seattle-a2b.com/"
      url += "otp/routers/default/plan?fromPlace="

      case mode
      when 'TRANSIT'
        url += "#{origin}&toPlace=#{destination}"
      when 'WALK' # either entire trip or first leg of car2go trip
        url += "#{@origin.join(',')}&toPlace=#{destination}&mode=WALK"
      when 'CAR'  # second leg of car2go trip
        url += "#{origin}&toPlace=#{@destination.join(',')}&mode=CAR"
      end
      p=HTTParty.get(url)['plan']
      puts "!"*80, "url: #{url}", "@"*80, "plan: #{p}", "#"*80
      p
    end

		def directions(legs) # array of trip legs, e.g. [walk, car] or [walk, bus, bus, walk]
			dir_array = []
			legs.each do |leg|
				if leg['mode'] == 'WALK' || leg['mode'] == 'CAR'
					l = StreetLeg.new(street_hash(leg))
					leg['steps'].each { |step| l.turns << Turn.new(turn_hash(step)) }
					dir_array << l
				else
					l = TransitLeg.new(transit_hash(leg))
					l.stops << Stop.new(stop_hash(leg, 'from')) # get on bus at
					l.stops << Stop.new(stop_hash(leg, 'to')) # get off bus at
					dir_array << l
				end
			end
			dir_array
		end

    def street_hash(leg)
      { mode: leg['mode'],
        start_time: leg['startTime']/1000,
        end_time: leg['endTime']/1000 }
      end

    def turn_hash(step)
      { street: step['streetName'],
        abs_direction: step['absoluteDirection'],
        rel_direction: step['relativeDirection'],
        distance: step['distance'] }
    end

    def transit_hash(leg)
      { mode: leg['mode'],
        route: leg['route'],
        headsign: leg['headsign'],
        continuation?: leg['interlineWithPreviousLeg'],
        express?: leg['tripShortName'] == 'EXPRESS' }
    end

    def stop_hash(leg, to_from)
      { name: leg[to_from]['name'],
        stop_id: leg[to_from]['stopId']['id'],
        scheduled: leg[to_from]['departure']/1000,
        actual: leg[to_from]['departure']/1000 }
    end
end
