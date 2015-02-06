require 'trip'

class WalkTrip < Trip

  def initialize(origin, destination)
    @plan = otp_routes('WALK', origin, destination)
  end

  def route
    return nil unless @plan # workaround for OTP API bug

    walk_directions = directions(@plan['itineraries'][0]['legs'])

    { from: @plan['from']['name'],
      to: 	@plan['to']['name'],
      directions: walk_directions
    }
  end

end
