# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'yaml'
require_relative '../lib/annotation'
require_relative '../lib/book'
require_relative '../lib/library'
require_relative '../lib/export'

class ExportTest < Minitest::Test
  STUB = [Annotation.new(text: 'x', note: '', chapter: '', modified: Time.utc(2024, 1, 1))].freeze

  def test_creates_directory_when_missing
    Dir.mktmpdir do |dir|
      nested = File.join(dir, "sub_#{rand(1000)}", 'highlights')
      Export.new(build_library, nested).save
      assert File.directory?(nested), 'Export did not create missing directory'
    end
  end

  def test_writes_one_file_per_book
    Dir.mktmpdir do |dir|
      Export.new(build_library, dir).save
      files = Dir.glob(File.join(dir, '*.md'))
      assert_equal 2, files.length, 'Export did not write one file per book'
    end
  end

  def test_creates_file_with_sanitized_name
    Dir.mktmpdir do |dir|
      Export.new(build_library, dir).save
      assert File.exist?(File.join(dir, 'Deep Work.md')), 'Export did not create file with sanitized name'
      assert File.exist?(File.join(dir, 'Thinking, Fast & Slow.md')),
             'Export did not preserve safe special characters in filename'
    end
  end

  def test_preserves_themes_on_reexport
    Dir.mktmpdir do |dir|
      Export.new(build_library, dir).save
      path = File.join(dir, 'Deep Work.md')
      content = File.read(path)
      content.sub!('themes: []', "themes:\n- focus\n- productivity")
      File.write(path, content)
      Export.new(build_library, dir).save
      yaml = parse_frontmatter(File.read(path))
      assert_equal %w[focus productivity], yaml['themes'], 'Themes were not preserved on re-export'
    end
  end

  def test_new_file_gets_default_status
    Dir.mktmpdir do |dir|
      Export.new(build_library, dir).save
      path = File.join(dir, 'Deep Work.md')
      yaml = parse_frontmatter(File.read(path))
      assert_equal 'raw', yaml['status'], 'New file did not get default status'
    end
  end

  def test_file_content_contains_annotations
    Dir.mktmpdir do |dir|
      Export.new(build_library, dir).save
      content = File.read(File.join(dir, 'Deep Work.md'))
      assert_includes content, '> Focus is a skill', 'Export file did not contain annotation blockquote'
      assert_includes content, '### Rule 1', 'Export file did not contain chapter heading'
    end
  end

  def test_strips_filesystem_unsafe_characters_from_filename
    Dir.mktmpdir do |dir|
      book = Book.new(
        identifier: "x#{rand(1000)}",
        title: 'Hello: World',
        author: 'Author',
        annotations: STUB
      )
      library = Library.new([book])
      Export.new(library, dir).save
      assert File.exist?(File.join(dir, 'Hello World.md')), 'Export did not strip colon from filename'
    end
  end

  def test_skips_file_for_book_with_no_renderable_annotations
    Dir.mktmpdir do |dir|
      book = Book.new(
        identifier: "x#{rand(1000)}",
        title: 'Empty Book',
        author: 'Author',
        annotations: [
          Annotation.new(text: '', note: '', chapter: '', modified: Time.utc(2024, 1, 1))
        ]
      )
      library = Library.new([book])
      Export.new(library, dir).save
      refute File.exist?(File.join(dir, 'Empty Book.md')),
             'File was created for book with no renderable annotations'
    end
  end

  def test_is_frozen_after_creation
    Dir.mktmpdir do |dir|
      export = Export.new(build_library, dir)
      assert export.frozen?, 'Export was not frozen after creation'
    end
  end

  def test_strips_leading_whitespace_from_slug
    Dir.mktmpdir do |dir|
      book = Book.new(
        identifier: "x#{rand(1000)}",
        title: '"Dance First"',
        author: 'Author',
        annotations: STUB
      )
      library = Library.new([book])
      Export.new(library, dir).save
      assert File.exist?(File.join(dir, 'Dance First.md')),
             'Export did not strip leading artifact from quoted title'
    end
  end

  def test_merges_books_with_duplicate_titles
    Dir.mktmpdir do |dir|
      book1 = Book.new(
        identifier: "x#{rand(1000)}",
        title: 'Meditations',
        author: 'Marcus Aurelius',
        annotations: [Annotation.new(text: 'First highlight', note: '', chapter: '', modified: Time.utc(2024, 1, 1))]
      )
      book2 = Book.new(
        identifier: "y#{rand(1000)}",
        title: 'Meditations',
        author: 'Marcus Aurelius',
        annotations: [Annotation.new(text: 'Second highlight', note: '', chapter: '', modified: Time.utc(2024, 2, 1))]
      )
      library = Library.new([book1, book2])
      Export.new(library, dir).save
      files = Dir.glob(File.join(dir, '*.md'))
      assert_equal 1, files.length, 'Duplicate titles did not merge into one file'
      content = File.read(files.first)
      assert_includes content, 'First highlight', 'Merged file did not contain first book highlight'
      assert_includes content, 'Second highlight', 'Merged file did not contain second book highlight'
    end
  end

  def test_skips_book_with_empty_title
    Dir.mktmpdir do |dir|
      book = Book.new(
        identifier: "x#{rand(1000)}",
        title: '  ',
        author: 'Author',
        annotations: STUB
      )
      library = Library.new([book])
      Export.new(library, dir).save
      files = Dir.glob(File.join(dir, '*.md'))
      assert_equal 0, files.length, 'File was created for book with blank title'
    end
  end

  def test_preserves_unicode_characters_in_filename
    Dir.mktmpdir do |dir|
      book = Book.new(
        identifier: "x#{rand(1000)}",
        title: "\u0412\u043E\u0439\u043D\u0430 \u0438 \u043C\u0438\u0440",
        author: 'Author',
        annotations: STUB
      )
      library = Library.new([book])
      Export.new(library, dir).save
      assert File.exist?(File.join(dir, "\u0412\u043E\u0439\u043D\u0430 \u0438 \u043C\u0438\u0440.md")),
             'Export did not preserve Cyrillic characters in filename'
    end
  end

  private

  def build_library
    book1 = Book.new(
      identifier: 'id1',
      title: 'Deep Work',
      author: 'Cal Newport',
      annotations: [
        Annotation.new(text: 'Focus is a skill', note: 'Important', chapter: 'Rule 1', modified: Time.utc(2024, 1, 1))
      ]
    )
    book2 = Book.new(
      identifier: 'id2',
      title: 'Thinking, Fast & Slow',
      author: 'Daniel Kahneman',
      annotations: [
        Annotation.new(text: 'Two systems', note: '', chapter: 'Part 1', modified: Time.utc(2024, 2, 1))
      ]
    )
    Library.new([book1, book2])
  end

  def parse_frontmatter(content)
    match = content.match(/\A---\n(.+?)\n---/m)
    YAML.safe_load(match[1])
  end
end
