# frozen_string_literal: true

# Converts an Apple Core Data timestamp (seconds since 2001-01-01)
# into a Ruby Time object.
class AppleEpoch
  OFFSET = 978_307_200

  # @param seconds [Numeric] Apple Core Data timestamp
  def initialize(seconds)
    @seconds = seconds
  end

  # @return [Time] the equivalent UTC time
  def time
    Time.at(@seconds + OFFSET).utc
  end
end
