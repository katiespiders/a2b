require 'trip'

class WalkTrip < Trip

  def initialize(origin, destination)
    @plan = otp_routes('WALK', origin, destination)
  end

  def route
    return nil unless @plan # workaround for OTP API bug

    itinerary = @plan['itineraries'][0]
    walk_directions = directions(itinerary['legs'])

    {
      from: @plan['from']['name'],
      to: 	@plan['to']['name'],
      time: itinerary['walkTime'],
      directions: walk_directions
    }
  end
end
