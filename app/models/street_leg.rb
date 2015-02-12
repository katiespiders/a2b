class StreetLeg
  attr_accessor :mode, :instructions

  def initialize(leg, source, nxt=nil)
    @source = source
    if source == 'otp'
      @mode = leg['mode']
      @duration = (leg['endTime'] - leg['startTime']) / 1000
      turns(leg['steps'])
    elsif source == 'google'
      @duration = leg['duration']['value']
      @distance = leg['distance']['value']
      turns(leg['steps'])
    end
    @instructions = 'placeholder'
  end

  def turns(steps)
    @turns = []
    steps.each { |step| @turns << Turn.new(step, @source) }
  end

  def instructions
    @turns.each do |turn|
    end
  end
end
