require 'google_trip'

class WalkTrip < GoogleTrip

  def initialize(origin, destination)
    @plan = routes('walking', geocode(origin), geocode(destination))[0]['legs']
  end

  def route
    walk_directions = directions(@plan, 'WALK')

    {
      from: @plan[0]['start_address'],
      to: 	@plan[0]['end_address'],
      duration: @plan[0]['duration']['value'],
      distance: @plan[0]['distance']['value'],
      directions: walk_directions
    }
  end
end
