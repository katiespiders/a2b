class Turn

  def initialize(step, source)
    @instructions = source == 'otp' ? otp_instructions(step) : google_instructions(step)
  end

  private
    def otp_instructions(step)
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
    end

    def google_instructions(step)
      @distance = step['distance']['value']
      instructions = step['html_instructions']
    end
end
