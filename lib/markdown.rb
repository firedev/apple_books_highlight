# frozen_string_literal: true

require 'yaml'

# Renders a single Book as a complete Markdown file with
# YAML frontmatter and annotations as blockquotes.
class Markdown
  # @param book [Book] the book to render
  # @param frontmatter [Hash] preserved fields (:themes, :status)
  def initialize(book, frontmatter)
    @book = book
    @frontmatter = frontmatter
    freeze
  end

  # @return [String] complete Markdown file content
  def render
    header + body
  end

  private

  # @return [String] YAML frontmatter block
  def header
    yaml = {
      'kind' => 'book',
      'status' => @frontmatter[:status],
      'themes' => @frontmatter[:themes],
      'title' => @book.title,
      'author' => @book.author,
      'asset_id' => @book.identifier,
      'annotations' => @book.annotations.reject { |a| a.text.strip.empty? }.count
    }
    "---\n#{YAML.dump(yaml).delete_prefix("---\n")}---\n"
  end

  # @return [String] annotation body grouped by chapter
  def body
    lines = []
    chapter = nil
    @book.annotations.each do |a|
      next if a.text.strip.empty?
      lines.concat(heading(a, chapter))
      lines.concat(passage(a))
      chapter = a.chapter unless a.chapter.empty?
    end
    "\n#{lines.join("\n")}"
  end

  # @param annotation [Annotation] current annotation
  # @param previous [String, nil] previous chapter name
  # @return [Array<String>] chapter heading lines or empty
  def heading(annotation, previous)
    return [] if annotation.chapter.empty?
    return [] if annotation.chapter == previous
    ["### #{annotation.chapter}", '']
  end

  # @param annotation [Annotation] a single highlight
  # @return [Array<String>] Markdown lines for one annotation
  def passage(annotation)
    quoted = annotation.text.gsub(/^[ \t]+/, '').squeeze(' ').gsub("\n", "\n> ")
    lines = ["> #{quoted}", '']
    lines.concat(["*Note: #{annotation.note}*", '']) if annotation.noted?
    lines
  end
end
