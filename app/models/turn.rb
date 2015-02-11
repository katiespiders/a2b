class Turn
  attr_accessor :html

  def initialize(step, source)
    @step = step
    @html = source == 'otp' ? otp_html : google_html
  end

  private
    def otp_html
      street = @step['streetName']
      abs_direction = @step['absoluteDirection'].downcase
      rel_direction = @step['relativeDirection'].gsub('_', ' ').downcase
      distance = @step['distance']

      directions = if rel_direction == 'DEPART'
        "Head #{abs_direction} on #{street}"
      elsif rel_direction == 'CONTINUE'
        "Continue #{abs_direction} on #{street}"
      else
        "Turn #{rel_direction} onto #{street}"
      end

  		(directions + " for #{distance} meters.\n").html_safe
    end

    def google_html
      distance = @step['distance']['value']
      @step['html_instructions'] + " for #{distance} meters.\n"
    end
end
