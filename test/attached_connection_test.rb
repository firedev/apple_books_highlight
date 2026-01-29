# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'sqlite3'
require_relative '../lib/attached_connection'

class AttachedConnectionTest < Minitest::Test
  def test_attaches_secondary_database_as_books
    Dir.mktmpdir do |dir|
      primary = File.join(dir, 'primary.sqlite')
      secondary = File.join(dir, 'secondary.sqlite')
      seed_primary(primary)
      seed_secondary(secondary)
      connection = AttachedConnection.new(primary, secondary)
      result = connection.open do |db|
        db.execute("SELECT name FROM books.sqlite_master WHERE type='table'")
      end
      tables = result.map { |row| row['name'] }
      assert_includes tables, 'items', 'Attached database did not expose expected table'
    end
  end

  def test_returns_block_result
    Dir.mktmpdir do |dir|
      primary = File.join(dir, 'primary.sqlite')
      secondary = File.join(dir, 'secondary.sqlite')
      seed_primary(primary)
      seed_secondary(secondary)
      connection = AttachedConnection.new(primary, secondary)
      result = connection.open { |_db| 42 }
      assert_equal 42, result, 'AttachedConnection did not return the block result'
    end
  end

  private

  def seed_primary(path)
    db = SQLite3::Database.new(path)
    db.execute('CREATE TABLE data (id INTEGER)')
    db.close
  end

  def seed_secondary(path)
    db = SQLite3::Database.new(path)
    db.execute('CREATE TABLE items (id INTEGER)')
    db.close
  end
end
