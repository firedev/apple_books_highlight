# Apple Books Highlights for Obsidian

Exports your Apple Books highlights into an Obsidian vault as Markdown files — one per book, with YAML frontmatter.

Point it at your vault and each book becomes a note you can tag, link, and query.

## Usage

```bash
bin/highlights ~/obsidian-vault/books
```

## Output

```markdown
---
kind: book
status: raw
themes: []
title: "Be Here Now"
author: "Ram Dass"
asset_id: "1FD86D65F77F848B9BB52CAB16564AA3"
annotations: 3
---

### Chapter 1

> My colleagues and I were 9 to 5 psychologists.

*Note: This connects to the maya concept*
```

Re-running preserves manually edited `themes` and `status` fields.

## Tests

```bash
bundle exec ruby -Ilib -Itest -e 'Dir.glob("test/*_test.rb").each { |f| require_relative f }'
```

## Installation

### Requirements

- macOS (Apple Books stores highlights locally)
- Ruby 3.1 or later (macOS system Ruby 2.6.10 is not supported)

### 1. Install Ruby

Pick one:

**Homebrew (simplest):**

```bash
brew install ruby
```

**rbenv (version manager):**

```bash
brew install rbenv
rbenv install 3.3.0
rbenv global 3.3.0
```

**asdf (version manager):**

```bash
asdf plugin add ruby
asdf install ruby 3.3.0
asdf global ruby 3.3.0
```

### 2. Clone the repo

```bash
git clone git@github.com:firedev/apple_books_highlight.git
cd apple_books_highlight
```

### 3. Install dependencies

```bash
bundle install
```

### 4. Run

```bash
bin/highlights ~/path/to/your/obsidian-vault/books
```
