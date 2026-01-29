# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/annotation'
require_relative '../lib/book'

class BookTest < Minitest::Test
  def test_exposes_title_and_author
    book = Book.new(identifier: 'abc', title: 'My Book', author: 'Author', annotations: [])
    assert_equal 'My Book', book.title, 'Book title was not preserved'
    assert_equal 'Author', book.author, 'Book author was not preserved'
  end

  def test_count_returns_number_of_annotations
    annotations = Array.new(3) do
      Annotation.new(text: 't', note: '', chapter: '', modified: Time.now.utc)
    end
    book = Book.new(identifier: 'x', title: 'T', author: 'A', annotations: annotations)
    assert_equal 3, book.count, 'Book did not report correct annotation count'
  end

  def test_annotations_are_frozen
    book = Book.new(identifier: 'x', title: 'T', author: 'A', annotations: [])
    assert book.annotations.frozen?, 'Book annotations array was not frozen'
  end

  def test_is_frozen_after_creation
    book = Book.new(identifier: 'x', title: 'T', author: 'A', annotations: [])
    assert book.frozen?, 'Book was not frozen after creation'
  end
end
