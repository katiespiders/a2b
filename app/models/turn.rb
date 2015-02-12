class Turn

  def initialize(step, source)
    @html = source == 'otp' ? otp_html(step) : google_html(step)
  end

  private
    def otp_html(step)
      street = step['streetName']
      abs_direction = step['absoluteDirection'].downcase
      rel_direction = step['relativeDirection'].gsub('_', ' ').downcase
      @distance = step['distance']

      directions = if rel_direction == 'depart'
        "Head #{abs_direction} on #{street}"
      elsif rel_direction == 'continue'
        "Continue #{abs_direction} on #{street}"
      else
        "Turn #{rel_direction} onto #{street}"
      end

  		directions
    end

    def google_html(step)
      @distance = step['distance']['value']
      step['html_instructions']
    end
end
