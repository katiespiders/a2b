class TransitLeg

  def initialize(leg)
    @mode = leg['mode']
    @route = leg['route']
    @headsign = leg['headsign']
    @continuation = leg['interlineWithPreviousLeg']
    @express = leg['tripShortName'] == 'EXPRESS'
    @stops = [ Stop.new(leg['from']), Stop.new(leg['to']) ]
  end

  def to_s
    "Catch the #@route} #@mode.downcase} #@headsign} at #@stops[0]}. Get off at #@stops[1]}."
  end
end
