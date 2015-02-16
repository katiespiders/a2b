class TransitLeg
  attr_accessor :route, :headsign, :continuation, :stops, :instructions

  def initialize(leg, next_mode=nil)
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
    @duration = @stops[:off].actual - @stops[:on].actual
    @next_mode = next_mode
  end

	def trip_id(id)
		if @agency == 'KCM' # King County Metro
			'1_' + id
    elsif @agency == 'ST' # Sound Transit
			'40_' + id
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
    Time.at(epoch).strftime("%-I:%M %P")
  end
end
