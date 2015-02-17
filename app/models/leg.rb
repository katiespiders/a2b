class Leg
  attr_accessor :prev_leg, :next_leg

  def initialize(otp_hash)
    @mode = otp_hash['mode']
    if @mode == 'WALK'
      @from = [ otp_hash['from']['lat'], otp_hash['from']['lon'] ]
      @to = [ otp_hash['to']['lat'], otp_hash['to']['lon'] ]
      @duration = otp_hash['duration']
    else
      @route = otp_hash['route']
      @headsign = otp_hash['headsign']
      @continuation = otp_hash['interlineWithPreviousLeg']
      realtime_arrival(otp_hash)
    end
  end

  private
    def realtime_arrival(hsh)
      trip_id = '1_' + hsh['tripId']

      @stops = {
        on: Stop.new(hsh['from'], trip_id),
        off: Stop.new(hsh['to'], trip_id)
      }

      @duration = @stops[:off].time - @stops[:on].time
      @start_time = @stops[:on].time_string
      @end_time = @stops[:off].time_string
    end
end
