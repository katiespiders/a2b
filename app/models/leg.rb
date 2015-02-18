class Leg
  attr_accessor :route

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
      @board = Stop.new(otp_hash['from'], user_arrival_time: Time.now, route: @route)
      @alight = Stop.new(otp_hash['to'], trip_id: @board.trip_id)
      @duration = @alight.time - @board.time
      @start_time = @board.time_string
      @end_time = @alight.time_string
    end
end
