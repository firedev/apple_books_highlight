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
