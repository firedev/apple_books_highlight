# frozen_string_literal: true

# Locates the first *.sqlite file inside a given directory.
class DatabasePath
  # @param directory [String] path to search for a .sqlite file
  def initialize(directory)
    @directory = directory
  end

  # @return [String] absolute path to the found .sqlite file
  # @raise [RuntimeError] when no .sqlite file exists in the directory
  def path
    entries = Dir.glob(File.join(@directory, '*.sqlite'))
    raise "No .sqlite file found in #{@directory}" if entries.empty?

    entries.first
  end
end
