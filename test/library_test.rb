# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/book'
require_relative '../lib/library'

class LibraryTest < Minitest::Test
  def test_count_returns_number_of_books
    books = Array.new(2) do |i|
      Book.new(identifier: i.to_s, title: "Book #{i}", author: 'A', annotations: [])
    end
    library = Library.new(books)
    assert_equal 2, library.count, 'Library did not report correct book count'
  end

  def test_books_are_frozen
    library = Library.new([])
    assert library.books.frozen?, 'Library books array was not frozen'
  end

  def test_is_frozen_after_creation
    library = Library.new([])
    assert library.frozen?, 'Library was not frozen after creation'
  end
end
