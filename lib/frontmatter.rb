# frozen_string_literal: true

require 'yaml'

# Parses existing Markdown file frontmatter and preserves
# user-edited fields across re-exports.
class Frontmatter
  DEFAULTS = { themes: [], status: 'raw' }.freeze

  # @param path [String] absolute path to the Markdown file
  def initialize(path)
    @path = path
    freeze
  end

  # @return [Hash] preserved themes and status from existing file
  def preserved
    return DEFAULTS unless File.exist?(@path)

    parse(File.read(@path))
  end

  private

  # @param content [String] raw file content
  # @return [Hash] extracted themes and status or defaults
  def parse(content)
    match = content.match(/\A---\n(.+?)\n---/m)
    return DEFAULTS unless match

    yaml = YAML.safe_load(match[1], permitted_classes: [Symbol])
    return DEFAULTS unless yaml.is_a?(Hash)

    {
      themes: Array(yaml['themes']),
      status: yaml.fetch('status', DEFAULTS[:status])
    }
  rescue Psych::SyntaxError
    DEFAULTS
  end
end
