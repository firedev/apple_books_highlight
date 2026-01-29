# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/database_path'

class DatabasePathTest < Minitest::Test
  def test_finds_sqlite_file_in_directory
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'data.sqlite')
      FileUtils.touch(path)
      result = DatabasePath.new(dir).path
      assert_equal path, result, 'DatabasePath did not find the sqlite file'
    end
  end

  def test_raises_when_no_sqlite_file_exists
    Dir.mktmpdir do |dir|
      error = assert_raises(RuntimeError) { DatabasePath.new(dir).path }
      assert_includes error.message, dir, 'Error message did not include the directory path'
    end
  end
end
