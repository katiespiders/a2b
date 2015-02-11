class TransitLeg

  def initialize(leg)
    @mode = leg['mode']
    @route = leg['route']
    @headsign = leg['headsign']
		@agency = leg['agencyId']
		@trip_id = trip_id(leg['tripId'])
    @continuation = leg['interlineWithPreviousLeg']
    @express = leg['tripShortName'] == 'EXPRESS'
    @stops = [ Stop.new(leg['from'], @trip_id), Stop.new(leg['to'], @trip_id) ]
  end

	def trip_id(id)
		if @agency == 'KCM' # King County Metro
			'1_' + id
    elsif @agency == 'ST' # Sound Transit
			'40_' + id
		end
	end
end
