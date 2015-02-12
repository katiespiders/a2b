class TransitLeg
  attr_accessor :route, :headsign, :continuation, :stops

  def initialize(leg, nxt=nil)
    @mode = leg['mode']
    @route = leg['route']
    @headsign = leg['headsign']
		@agency = leg['agencyId']
		@trip_id = trip_id(leg['tripId'])
    @continuation = leg['interlineWithPreviousLeg']
    @express = leg['tripShortName'] == 'EXPRESS'
    @stops = {
      on: Stop.new(leg['from'], @trip_id),
      off: Stop.new(leg['to'], @trip_id)
    }
    @instructions = instructions(nxt)
  end

	def trip_id(id)
		if @agency == 'KCM' # King County Metro
			'1_' + id
    elsif @agency == 'ST' # Sound Transit
			'40_' + id
		end
	end

  def instructions(nxt)
    on = @stops[:on]
    str = if on.real_time
      "Catch the #{@route} towards #{@headsign} at #{time(on.arrival)} (#{offset(on)}) at #{on.name}. "
    else
      "Catch the #{@route} towards #{@headsign} at #{on.name}, supposedly at #{time(on.arrival)}. "
    end

    if nxt && nxt.instance_of?(TransitLeg) && nxt.continuation
        str += "Stay on the #{nxt.route} and get off at #{nxt.stops[:off].name}."
    else
      str += "Get off at #{@stops[:off].name}."
    end
  end

  def offset(stop)
    if stop.delay.abs < 60
      'on time'
    elsif stop.delay < 0
      "#{stop.delay/60} minutes early"
    else
      "#{stop.delay/60} minutes late"
    end
  end

  def time(epoch)
    Time.at(epoch).strftime("%-I:%M")
  end
end
