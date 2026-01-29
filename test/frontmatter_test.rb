# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'yaml'
require_relative '../lib/frontmatter'

class FrontmatterTest < Minitest::Test
  def test_returns_defaults_when_file_does_not_exist
    path = File.join(Dir.mktmpdir, "nonexistent_#{rand(1000)}.md")
    result = Frontmatter.new(path).preserved
    assert_equal [], result[:themes], 'Themes were not defaulted to empty array for missing file'
    assert_equal 'raw', result[:status], 'Status was not defaulted to raw for missing file'
  end

  def test_preserves_custom_themes_and_status
    Dir.mktmpdir do |dir|
      path = File.join(dir, "book_#{rand(1000)}.md")
      File.write(path, <<~MD)
        ---
        kind: book
        status: reviewed
        themes:
        - philosophy
        - mindfulness
        title: "Some Book"
        ---

        > A highlight
      MD
      result = Frontmatter.new(path).preserved
      assert_equal %w[philosophy mindfulness], result[:themes], 'Custom themes were not preserved'
      assert_equal 'reviewed', result[:status], 'Custom status was not preserved'
    end
  end

  def test_returns_defaults_when_themes_missing
    Dir.mktmpdir do |dir|
      path = File.join(dir, "book_#{rand(1000)}.md")
      File.write(path, <<~MD)
        ---
        kind: book
        title: "Some Book"
        ---

        > A highlight
      MD
      result = Frontmatter.new(path).preserved
      assert_equal [], result[:themes], 'Themes were not defaulted when missing from frontmatter'
      assert_equal 'raw', result[:status], 'Status was not defaulted when missing from frontmatter'
    end
  end

  def test_returns_defaults_for_malformed_frontmatter
    Dir.mktmpdir do |dir|
      path = File.join(dir, "book_#{rand(1000)}.md")
      File.write(path, "not valid frontmatter at all\n> just a quote\n")
      result = Frontmatter.new(path).preserved
      assert_equal [], result[:themes], 'Themes were not defaulted for malformed frontmatter'
      assert_equal 'raw', result[:status], 'Status was not defaulted for malformed frontmatter'
    end
  end

  def test_is_frozen_after_creation
    path = File.join(Dir.mktmpdir, "nonexistent_#{rand(1000)}.md")
    frontmatter = Frontmatter.new(path)
    assert frontmatter.frozen?, 'Frontmatter was not frozen after creation'
  end
end
