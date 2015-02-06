class StreetLeg
  attr_accessor :mode

  def initialize(leg)
    @mode = leg['mode']
    @start_time = leg['start_time']
    @end_time = leg['end_time']
    turns(leg['steps'])
  end

  def turns(steps)
    @turns = []
    steps.each { |step| @turns << Turn.new(step) }
  end

  def to_s
    str = ""
    @turns.each { |turn| str += "#{turn.to_s}. " }
    str
  end
end
