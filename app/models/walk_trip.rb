class WalkTrip < GoogleTrip
  attr_accessor :trip

  def initialize(origin, destination)
    @route = routes('walking', geocode(origin), geocode(destination))[0]['legs']
    @trip = set_route
  end

  def set_route
    walk_directions = directions(@route, 'WALK')

    {
      from: @route[0]['start_address'],
      to: 	@route[0]['end_address'],
      duration: @route[0]['duration']['value'],
      distance: @route[0]['distance']['value'],
      directions: walk_directions
    }
  end
end
