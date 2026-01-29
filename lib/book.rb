# frozen_string_literal: true

# Immutable value object representing a book with its
# collected annotations.
class Book
  attr_reader :identifier, :title, :author, :annotations

  # @param identifier [String] Apple Books asset ID
  # @param title [String] book title
  # @param author [String] book author
  # @param annotations [Array<Annotation>] highlights for this book
  def initialize(identifier:, title:, author:, annotations:)
    @identifier = identifier
    @title = title
    @author = author
    @annotations = annotations.freeze
    freeze
  end

  # @return [Integer] number of annotations
  def count
    @annotations.length
  end
end
