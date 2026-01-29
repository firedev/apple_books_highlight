# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/annotation'

class AnnotationTest < Minitest::Test
  def test_exposes_all_attributes
    time = Time.utc(2024, 6, 15)
    annotation = Annotation.new(text: 'highlighted', note: 'my note', chapter: 'Ch 1', modified: time)
    assert_equal 'highlighted', annotation.text, 'Annotation text was not preserved'
    assert_equal 'my note', annotation.note, 'Annotation note was not preserved'
    assert_equal 'Ch 1', annotation.chapter, 'Annotation chapter was not preserved'
    assert_equal time, annotation.modified, 'Annotation modified time was not preserved'
  end

  def test_noted_returns_true_when_note_present
    annotation = Annotation.new(text: 'text', note: 'exists', chapter: '', modified: Time.now.utc)
    assert annotation.noted?, 'Annotation with note was not detected as noted'
  end

  def test_noted_returns_false_when_note_empty
    annotation = Annotation.new(text: 'text', note: '', chapter: '', modified: Time.now.utc)
    refute annotation.noted?, 'Annotation without note was incorrectly detected as noted'
  end

  def test_is_frozen_after_creation
    annotation = Annotation.new(text: 'text', note: '', chapter: '', modified: Time.now.utc)
    assert annotation.frozen?, 'Annotation was not frozen after creation'
  end
end
