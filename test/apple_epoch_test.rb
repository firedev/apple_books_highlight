# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/apple_epoch'

class AppleEpochTest < Minitest::Test
  def test_converts_apple_timestamp_to_utc_time
    seconds = 726_019_200.0
    result = AppleEpoch.new(seconds).time
    expected = Time.utc(2024, 1, 4, 0, 0, 0)
    assert_equal expected, result, 'AppleEpoch did not convert timestamp to correct UTC time'
  end

  def test_converts_zero_to_apple_epoch_origin
    result = AppleEpoch.new(0).time
    expected = Time.utc(2001, 1, 1, 0, 0, 0)
    assert_equal expected, result, 'AppleEpoch did not treat zero as 2001-01-01 origin'
  end

  def test_handles_fractional_seconds
    seconds = 726_019_200.5
    result = AppleEpoch.new(seconds).time
    assert_in_delta 0.5, result.subsec.to_f, 0.001, 'AppleEpoch did not preserve fractional seconds'
  end
end
