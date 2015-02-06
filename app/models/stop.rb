class Stop

  def initialize(stop)
    @name = stop['name']
    @stop_id = stop['stopId']['id']
    @scheduled = stop['departure']
    @actual = stop['departure']
  end

  def to_s
    "#{@name} at #{Time.at(@scheduled/1000).strftime("%H:%M")}"
  end
end
