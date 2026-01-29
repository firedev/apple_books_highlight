# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'
require_relative '../lib/annotation'
require_relative '../lib/book'
require_relative '../lib/markdown'

class MarkdownTest < Minitest::Test
  def test_renders_yaml_frontmatter_with_book_metadata
    output = render_default
    yaml = parse_frontmatter(output)
    assert_equal 'book', yaml['kind'], 'Frontmatter did not include kind: book'
    assert_equal 'Deep Work', yaml['title'], 'Frontmatter did not include book title'
    assert_equal 'Cal Newport', yaml['author'], 'Frontmatter did not include book author'
    assert_equal 'id1', yaml['asset_id'], 'Frontmatter did not include asset_id'
    assert_equal 2, yaml['annotations'], 'Frontmatter did not include annotation count'
  end

  def test_preserves_themes_and_status_from_frontmatter
    frontmatter = { themes: %w[focus productivity], status: 'reviewed' }
    output = render_with(frontmatter: frontmatter)
    yaml = parse_frontmatter(output)
    assert_equal %w[focus productivity], yaml['themes'], 'Preserved themes were not rendered'
    assert_equal 'reviewed', yaml['status'], 'Preserved status was not rendered'
  end

  def test_renders_annotations_as_blockquotes
    output = render_default
    assert_includes output, '> Focus is a skill', 'Annotation was not rendered as blockquote'
  end

  def test_groups_annotations_under_chapter_headings
    output = render_default
    assert_includes output, '### Rule 1', 'Chapter heading was not rendered'
  end

  def test_renders_note_after_highlighted_passage
    output = render_default
    assert_includes output, '*Note: Important insight*', 'Note was not rendered after highlight'
  end

  def test_omits_note_line_when_annotation_has_no_note
    book = build_book(annotations: [
                        Annotation.new(text: 'No note here', note: '', chapter: '', modified: Time.utc(2024, 1, 1))
                      ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    refute_includes output, '*Note:', 'Note line appeared for annotation without note'
  end

  def test_omits_chapter_heading_when_chapter_empty
    book = build_book(annotations: [
                        Annotation.new(text: 'Orphan quote', note: '', chapter: '', modified: Time.utc(2024, 1, 1))
                      ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    refute_includes output, '###', 'Chapter heading appeared for empty chapter'
  end

  def test_emits_chapter_heading_once_for_shared_chapter
    book = build_book(annotations: [
      Annotation.new(text: 'First point', note: '', chapter: 'Rule 1', modified: Time.utc(2024, 1, 1)),
      Annotation.new(text: 'Second point', note: '', chapter: 'Rule 1', modified: Time.utc(2024, 1, 2))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    assert_equal 1, output.scan('### Rule 1').length, 'Chapter heading was emitted more than once for same chapter'
  end

  def test_renders_chapter_then_quote_then_note_in_order
    book = build_book(annotations: [
      Annotation.new(text: 'Key idea', note: 'Remember this', chapter: 'Ch 3', modified: Time.utc(2024, 1, 1))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    chapter = output.index('### Ch 3')
    quote = output.index('> Key idea')
    note = output.index('*Note: Remember this*')
    assert chapter < quote, 'Chapter heading did not precede blockquote'
    assert quote < note, 'Blockquote did not precede note'
  end

  def test_renders_single_blank_line_between_blockquote_and_note
    book = build_book(annotations: [
      Annotation.new(text: 'Deep focus', note: 'Key takeaway', chapter: '', modified: Time.utc(2024, 1, 1))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    assert_includes output, "> Deep focus\n\n*Note: Key takeaway*",
                    'Note was not separated from blockquote by exactly one blank line'
  end

  def test_is_frozen_after_creation
    markdown = Markdown.new(build_book, { themes: [], status: 'raw' })
    assert markdown.frozen?, 'Markdown was not frozen after creation'
  end

  def test_quotes_yaml_title_containing_colon
    book = build_book(title: 'Work: A History')
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    yaml = parse_frontmatter(output)
    assert_equal 'Work: A History', yaml['title'], 'Title with colon was not properly quoted in YAML'
  end

  def test_renders_multiline_highlight_as_continuous_blockquote
    book = build_book(annotations: [
      Annotation.new(text: "line one\nline two\nline three", note: '', chapter: '', modified: Time.utc(2024, 1, 1))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    assert_includes output, "> line one\n> line two\n> line three",
                    'Multiline highlight did not prefix each line with blockquote marker'
  end

  def test_does_not_duplicate_chapter_after_empty_chapter_interruption
    book = build_book(annotations: [
      Annotation.new(text: 'First', note: '', chapter: 'Chapter 1', modified: Time.utc(2024, 1, 1)),
      Annotation.new(text: 'Middle', note: '', chapter: '', modified: Time.utc(2024, 1, 2)),
      Annotation.new(text: 'Last', note: '', chapter: 'Chapter 1', modified: Time.utc(2024, 1, 3))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    assert_equal 1, output.scan('### Chapter 1').length,
                 'Chapter heading was duplicated after empty chapter interruption'
  end

  def test_counts_only_nonempty_annotations_in_frontmatter
    book = build_book(annotations: [
      Annotation.new(text: '', note: '', chapter: '', modified: Time.utc(2024, 1, 1)),
      Annotation.new(text: 'Real highlight', note: '', chapter: '', modified: Time.utc(2024, 1, 2))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    yaml = parse_frontmatter(output)
    assert_equal 1, yaml['annotations'], 'Frontmatter count included empty-text annotations'
  end

  def test_strips_leading_whitespace_from_blockquote_lines
    book = build_book(annotations: [
      Annotation.new(text: "\t\t\t— Tenzin Gyatso\n\t\t\t14th dalai lama", note: '', chapter: '',
                     modified: Time.utc(2024, 1, 1))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    assert_includes output, "> — Tenzin Gyatso\n> 14th dalai lama",
                    'Leading whitespace was not stripped from blockquote lines'
  end

  def test_collapses_double_spaces_in_highlight_text
    book = build_book(annotations: [
      Annotation.new(text: 'No university  would accept', note: '', chapter: '', modified: Time.utc(2024, 1, 1))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    assert_includes output, '> No university would accept',
                    'Double spaces were not collapsed in highlight text'
  end

  def test_skips_whitespace_only_annotation
    book = build_book(annotations: [
      Annotation.new(text: "\t\t\t", note: '', chapter: '', modified: Time.utc(2024, 1, 1)),
      Annotation.new(text: 'Real highlight', note: '', chapter: '', modified: Time.utc(2024, 1, 2))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    assert_equal 1, output.scan(/^> /).length, 'Whitespace-only annotation was not skipped'
  end

  def test_skips_annotation_with_empty_text
    book = build_book(annotations: [
      Annotation.new(text: '', note: '', chapter: '', modified: Time.utc(2024, 1, 1)),
      Annotation.new(text: 'Real highlight', note: '', chapter: '', modified: Time.utc(2024, 1, 2))
    ])
    output = Markdown.new(book, { themes: [], status: 'raw' }).render
    assert_equal 1, output.scan(/^> /).length, 'Empty annotation was rendered as empty blockquote'
    assert_includes output, '> Real highlight', 'Non-empty annotation was not rendered'
  end

  private

  def render_default
    render_with(frontmatter: { themes: [], status: 'raw' })
  end

  def render_with(frontmatter:)
    Markdown.new(build_book, frontmatter).render
  end

  def build_book(title: 'Deep Work', annotations: nil)
    annotations ||= [
      Annotation.new(text: 'Focus is a skill', note: 'Important insight', chapter: 'Rule 1',
                     modified: Time.utc(2024, 1, 1)),
      Annotation.new(text: 'Shallow work is easy', note: '', chapter: '', modified: Time.utc(2024, 1, 2))
    ]
    Book.new(identifier: 'id1', title: title, author: 'Cal Newport', annotations: annotations)
  end

  def parse_frontmatter(output)
    match = output.match(/\A---\n(.+?)\n---/m)
    YAML.safe_load(match[1])
  end
end
