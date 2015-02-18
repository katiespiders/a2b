class Leg
  attr_accessor :route, :mode, :duration, :start_time, :end_time

  def initialize(otp_hash, prev=nil)
    @mode = otp_hash['mode']
    @prev = prev
    if @mode == 'WALK'
      @from = [ otp_hash['from']['lat'], otp_hash['from']['lon'] ]
      @to = [ otp_hash['to']['lat'], otp_hash['to']['lon'] ]
      @duration = otp_hash['duration']
    else
      @route = otp_hash['route']
      @route += 'E' if otp_hash['tripShortName'] == 'EXPRESS'
      @headsign = otp_hash['headsign']
      @agency = otp_hash['agencyId']
      @continuation = otp_hash['interlineWithPreviousLeg']
      realtime_arrival(otp_hash)
    end
  end

  private
    def realtime_arrival(otp_hash)
      @duration = ( otp_hash['endTime'] - otp_hash['startTime'] ) / 1000
      @board = Stop.new(otp_hash['from'], user_arrival_time: Time.now, route: @route)
      @alight = Stop.new(otp_hash['to'], trip_id: @board.trip_id)
      @start_time = @board.time
      @end_time = @board.time + @duration
      @start_display = time_string(@start_time)
      @end_display = time_string(@end_time)
    end

    def time_string(time)
      Time.at(time).strftime("%-I:%M %P")
    end
end
