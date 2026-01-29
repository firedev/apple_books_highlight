# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'sqlite3'
require_relative '../lib/attached_connection'
require_relative '../lib/highlight_query'

class HighlightQueryTest < Minitest::Test
  def test_fetches_library_from_seeded_databases
    Dir.mktmpdir do |dir|
      annotations_path = File.join(dir, 'annotations.sqlite')
      books_path = File.join(dir, 'books.sqlite')
      seed_annotations(annotations_path)
      seed_books(books_path)
      connection = AttachedConnection.new(annotations_path, books_path)
      library = HighlightQuery.new(connection).fetch
      assert_equal 1, library.count, 'Library did not contain expected number of books'
      book = library.books.first
      assert_equal 'Test Book', book.title, 'Book title did not match seeded data'
      assert_equal 'Test Author', book.author, 'Book author did not match seeded data'
      assert_equal 2, book.count, 'Book did not contain expected number of annotations'
      assert_equal 'First highlight', book.annotations[0].text, 'First annotation text did not match'
      assert_equal 'Second highlight', book.annotations[1].text, 'Second annotation text did not match'
      assert_equal 'my note', book.annotations[0].note, 'Annotation note did not match seeded data'
    end
  end

  def test_excludes_deleted_annotations
    Dir.mktmpdir do |dir|
      annotations_path = File.join(dir, 'annotations.sqlite')
      books_path = File.join(dir, 'books.sqlite')
      seed_annotations_with_deleted(annotations_path)
      seed_books(books_path)
      connection = AttachedConnection.new(annotations_path, books_path)
      library = HighlightQuery.new(connection).fetch
      assert_equal 1, library.books.first.count, 'Deleted annotation was not excluded'
    end
  end

  private

  def seed_annotations(path)
    db = SQLite3::Database.new(path)
    db.execute(<<~SQL)
      CREATE TABLE ZAEANNOTATION (
        ZANNOTATIONASSETID TEXT,
        ZANNOTATIONSELECTEDTEXT TEXT,
        ZANNOTATIONNOTE TEXT,
        ZFUTUREPROOFING5 TEXT,
        ZANNOTATIONMODIFICATIONDATE REAL,
        ZANNOTATIONDELETED INTEGER DEFAULT 0,
        ZPLLOCATIONRANGESTART INTEGER DEFAULT 0
      )
    SQL
    db.execute(
      'INSERT INTO ZAEANNOTATION VALUES (?, ?, ?, ?, ?, ?, ?)',
      ['asset1', 'First highlight', 'my note', 'Chapter 1', 726_019_200.0, 0, 1]
    )
    db.execute(
      'INSERT INTO ZAEANNOTATION VALUES (?, ?, ?, ?, ?, ?, ?)',
      ['asset1', 'Second highlight', nil, nil, 726_019_300.0, 0, 2]
    )
    db.close
  end

  def seed_annotations_with_deleted(path)
    db = SQLite3::Database.new(path)
    db.execute(<<~SQL)
      CREATE TABLE ZAEANNOTATION (
        ZANNOTATIONASSETID TEXT,
        ZANNOTATIONSELECTEDTEXT TEXT,
        ZANNOTATIONNOTE TEXT,
        ZFUTUREPROOFING5 TEXT,
        ZANNOTATIONMODIFICATIONDATE REAL,
        ZANNOTATIONDELETED INTEGER DEFAULT 0,
        ZPLLOCATIONRANGESTART INTEGER DEFAULT 0
      )
    SQL
    db.execute(
      'INSERT INTO ZAEANNOTATION VALUES (?, ?, ?, ?, ?, ?, ?)',
      ['asset1', 'Kept highlight', nil, nil, 726_019_200.0, 0, 1]
    )
    db.execute(
      'INSERT INTO ZAEANNOTATION VALUES (?, ?, ?, ?, ?, ?, ?)',
      ['asset1', 'Deleted highlight', nil, nil, 726_019_300.0, 1, 2]
    )
    db.close
  end

  def seed_books(path)
    db = SQLite3::Database.new(path)
    db.execute(<<~SQL)
      CREATE TABLE ZBKLIBRARYASSET (
        ZASSETID TEXT,
        ZTITLE TEXT,
        ZAUTHOR TEXT
      )
    SQL
    db.execute(
      'INSERT INTO ZBKLIBRARYASSET VALUES (?, ?, ?)',
      ['asset1', 'Test Book', 'Test Author']
    )
    db.close
  end
end
