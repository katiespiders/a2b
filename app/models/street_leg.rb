class StreetLeg
  attr_accessor :mode

  def initialize(leg, source)
    @source = source
    if source == 'otp'
      @mode = leg['mode']
      @duration = leg['endTime'] - leg['startTime']
      turns(leg['steps'])
    elsif source == 'google'
      @duration = leg['duration']['value']
      @distance = leg['distance']['value']
      turns(leg['steps'])
    end
  end

  def turns(steps)
    @turns = []
    steps.each { |step| @turns << Turn.new(step, @source).html }
  end
end
