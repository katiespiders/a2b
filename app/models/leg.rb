class Leg
  attr_accessor :route, :mode, :duration, :start_time, :end_time, :xfer

  def initialize(otp_hash, start_time, xfer, first_transit)
    @mode = otp_hash['mode']
    @start_time = start_time

    if @mode == 'WALK'
      @duration = otp_hash['duration']
      @end_time = @start_time + @duration
      @origin = [ otp_hash['from']['lat'], otp_hash['from']['lon'] ]
      @destination = [ otp_hash['to']['lat'], otp_hash['to']['lon'] ]
    else
      @route = otp_hash['route']
      @route += 'E' if otp_hash['tripShortName'] == 'EXPRESS'
      @headsign = otp_hash['headsign']
      @agency = otp_hash['agencyId']
      @continuation = otp_hash['interlineWithPreviousLeg']
      @xfer = @continuation ? false : xfer
      realtime_arrival(otp_hash, first_transit)
    end
  end

  private
    def realtime_arrival(otp_hash, first_transit)
      @duration = (otp_hash['endTime'] - otp_hash['startTime']) / 1000
      @board = Stop.new(otp_hash['from'], user_arrival_time: @start_time, route: @route, get_oba: first_transit)
      @alight = Stop.new(otp_hash['to'])
      @start_time = @board.arrival_time
      @end_time = @start_time + @duration
      @start_display = time_string(@start_time)
      @end_display = time_string(@end_time)
    end

    def time_string(time)
      Time.at(time).strftime("%-I:%M %P")
    end
end
