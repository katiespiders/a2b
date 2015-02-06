require 'httparty'
require 'latitude'

class Trip
	def initialize(mode, origin, destination)
		@mode = mode
		@origin = origin
		@destination = destination
	end

  def itinerary
		case @mode
		when 'TRANSIT'
			TransitTrip.new(@origin, @destination)
		when 'CAR'
			CarTrip.new(@origin, @destination)
		when 'WALK'
			WalkTrip.new(@origin, @destination)
		end
	end

  def otp_routes(mode=@mode, origin=@origin, destination=@destination)
    origin = origin.join(',')
    destination = destination.join(',')
    url = Rails.env.production? ? "http://otp.seattle-a2b.com/" : "http://localhost:8080/"
    url += "otp/routers/default/plan?fromPlace="

    case mode
    when 'TRANSIT'
      url += "#{origin}&toPlace=#{destination}"
    when 'WALK' # either entire trip or first leg of car2go trip
      url += "#{@origin.join(',')}&toPlace=#{destination}&mode=WALK"
    when 'CAR'  # second leg of car2go trip
      url += "#{origin}&toPlace=#{@destination.join(',')}&mode=CAR"
    end
    HTTParty.get(url)['plan']
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

  private
    def street_hash(leg)
      { mode: leg['mode'],
        start_time: leg['startTime']/1000,
        end_time: leg['endTime']/1000
      }
    end

    def turn_hash(step)
      { street: step['streetName'],
        abs_direction: step['absoluteDirection'],
        rel_direction: step['relativeDirection'],
        distance: step['distance']
      }
    end

    def transit_hash(leg)
      { mode: leg['mode'],
        route: leg['route'],
        headsign: leg['headsign'],
        continuation?: leg['interlineWithPreviousLeg'],
        express?: leg['tripShortName'] == 'EXPRESS'
      }
    end

    def stop_hash(leg, to_from)
      { name: leg[to_from]['name'],
        stop_id: leg[to_from]['stopId']['id'],
        scheduled: leg[to_from]['departure']/1000,
        actual: leg[to_from]['departure']/1000
      }
    end
end
