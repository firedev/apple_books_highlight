# frozen_string_literal: true

require 'sqlite3'

# Opens a primary SQLite database and attaches a secondary one,
# enabling cross-database joins in a single SQL query.
class AttachedConnection
  # @param primary [String] path to the primary .sqlite file
  # @param attached [String] path to the secondary .sqlite file
  def initialize(primary, attached)
    @primary = primary
    @attached = attached
  end

  # @yield [SQLite3::Database] an open connection with the attached database
  # @return [Object] the block's return value
  def open(&block)
    db = SQLite3::Database.new(@primary)
    db.results_as_hash = true
    db.execute('ATTACH DATABASE ? AS books', [@attached])
    result = block.call(db)
    db.close
    result
  end
end
