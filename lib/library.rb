# frozen_string_literal: true

# Immutable collection of books with their annotations.
class Library
  attr_reader :books

  # @param books [Array<Book>] collected books
  def initialize(books)
    @books = books.freeze
    freeze
  end

  # @return [Integer] total number of books
  def count
    @books.length
  end
end
