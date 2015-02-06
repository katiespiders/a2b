class Turn

  def initialize(step)
    @street = step['streetName']
    @abs_direction = step['absoluteDirection']
    @rel_direction = step['relativeDirection']
    @distance = step['distance']
  end

  def to_s
    directions = if @rel_direction == 'DEPART'
      "Go #{@abs_direction} on #{@street} "
    elsif @rel_direction == 'CONTINUE'
      "Continue #{@abs_direction} on #{@street} "
    else
      "Turn #{@rel_direction.gsub('_', ' ')} to go #{@abs_direction} on #{@street} "
    end

    directions +  "for #{@distance} of some unit"
  end
end
