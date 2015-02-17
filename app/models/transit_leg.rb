class TransitLeg
  attr_accessor :route, :headsign, :continuation, :stops

  def initialize(leg, next_mode=nil)
    @mode = leg['mode']
    @next_mode = next_mode
    @route = leg['route']
    @headsign = leg['headsign']
    @continuation = leg['interlineWithPreviousLeg']
    
    realtime_arrival(leg)
  end

  private
    def realtime_arrival(leg)
      trip_id = '1_' + leg['tripId']

      @stops = {
        on: Stop.new(leg['from'], trip_id),
        off: Stop.new(leg['to'], trip_id)
      }

      @duration = @stops[:off].time - @stops[:on].time
      @times = {
        start: @stops[:on].time_string,
        end: @stops[:off].time_string
      }
    end
end
