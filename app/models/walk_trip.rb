require 'trip'

class WalkTrip < Trip

  def initialize(origin, destination)
    @mode = 'WALK'
    @origin = origin
    @destination = destination
    @plan = otp_routes
  end

  def route
    walk = otp_routes
    return nil unless walk # workaround for OTP API bug

    walk_directions = directions(walk['itineraries'][0]['legs'])

    { from: walk['from']['name'],
      to: 	walk['to']['name'],
      directions: walk_directions
    }
  end

end
