# frozen_string_literal: true

require_relative 'apple_epoch'
require_relative 'annotation'
require_relative 'book'
require_relative 'library'

# Executes the cross-database SQL query and transforms raw rows
# into a Library of Books with Annotations.
class HighlightQuery
  SQL = <<~SQL
    SELECT
      ZANNOTATIONASSETID AS asset_id,
      ZTITLE             AS title,
      ZAUTHOR            AS author,
      ZANNOTATIONSELECTEDTEXT AS text,
      ZANNOTATIONNOTE    AS note,
      ZFUTUREPROOFING5   AS chapter,
      ZANNOTATIONMODIFICATIONDATE AS modified
    FROM ZAEANNOTATION
    LEFT JOIN books.ZBKLIBRARYASSET
      ON ZANNOTATIONASSETID = ZASSETID
    WHERE ZANNOTATIONSELECTEDTEXT IS NOT NULL
      AND ZANNOTATIONDELETED = 0
    ORDER BY ZTITLE, ZPLLOCATIONRANGESTART
  SQL

  # @param connection [AttachedConnection] database connection wrapper
  def initialize(connection)
    @connection = connection
  end

  # @return [Library] all books with their annotations
  def fetch
    @connection.open do |db|
      rows = db.execute(SQL)
      grouped = rows.group_by { |row| row['asset_id'] }
      books = grouped.map { |_, group| build(group) }
      Library.new(books)
    end
  end

  private

  # @param rows [Array<Hash>] rows sharing the same asset_id
  # @return [Book]
  def build(rows)
    first = rows.first
    annotations = rows.map { |row| annotate(row) }
    Book.new(
      identifier: first['asset_id'].to_s,
      title: first['title'].to_s,
      author: first['author'].to_s,
      annotations: annotations
    )
  end

  # @param row [Hash] a single database row
  # @return [Annotation]
  def annotate(row)
    Annotation.new(
      text: row['text'].to_s,
      note: row['note'].to_s,
      chapter: row['chapter'].to_s,
      modified: AppleEpoch.new(row['modified'].to_f).time
    )
  end
end
