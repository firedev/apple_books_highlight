# frozen_string_literal: true

# Immutable value object representing a single highlight
# from Apple Books.
class Annotation
  attr_reader :text, :note, :chapter, :modified

  # @param text [String] highlighted passage
  # @param note [String] user note (empty string when absent)
  # @param chapter [String] chapter title (empty string when absent)
  # @param modified [Time] last modification timestamp
  def initialize(text:, note:, chapter:, modified:)
    @text = text
    @note = note
    @chapter = chapter
    @modified = modified
    freeze
  end

  # @return [Boolean] true when the user attached a note
  def noted?
    !@note.empty?
  end
end
