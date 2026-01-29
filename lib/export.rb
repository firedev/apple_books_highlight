# frozen_string_literal: true

require 'fileutils'
require_relative 'frontmatter'
require_relative 'markdown'

# Writes one Markdown file per book into a target directory,
# preserving user-edited frontmatter fields on re-export.
class Export
  # @param library [Library] collection of books to export
  # @param directory [String] target directory path
  def initialize(library, directory)
    @library = library
    @directory = directory
    freeze
  end

  # @return [void] writes one .md file per book
  def save
    FileUtils.mkdir_p(@directory)
    @library.books
      .reject { |b| b.title.strip.empty? }
      .group_by { |b| slug(b.title) }
      .each { |filename, books| write(merge(books), filename) }
  end

  private

  # @param book [Book] a single book to write
  # @param filename [String] sanitized .md filename
  # @return [void]
  def write(book, filename)
    return if book.annotations.all? { |a| a.text.strip.empty? }
    path = File.join(@directory, filename)
    preserved = Frontmatter.new(path).preserved
    content = Markdown.new(book, preserved).render
    File.write(path, content)
  end

  # @param books [Array<Book>] books sharing the same filename
  # @return [Book] single book with combined annotations
  def merge(books)
    return books.first if books.one?
    Book.new(
      identifier: books.first.identifier,
      title: books.first.title,
      author: books.first.author,
      annotations: books.flat_map(&:annotations)
    )
  end

  # @param title [String] book title
  # @return [String] sanitized filename
  def slug(title)
    "#{title.gsub(%r{[/\\:*?"<>|]}, '').strip.delete_prefix('.').delete_suffix('.')}.md"
  end
end
