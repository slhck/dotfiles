# Rules for Claude

## Markdown Output to Files

- Begin with a Level-1 Title. Use Level-2 headings for the rest of the document.
- ALWAYS include an empty paragraph after a heading or before list items.
- DO NOT use boldface excessively. Use it sparingly as you would do for normal written text.
- DO NOT insert horizontal rules.
- DO NOT automatically number headings. Use plain headings.
- DO NOT create another heading if what follows is only a brief section or list. In such a case, prefer a brief regular paragraph as an introduction.
- DO NOT use tables if there are only two columns. Use an unordered list instead.

## Git Commits

- DO NOT commit unless the user asked.
- DO use conventional format: <type>(<scope>): <subject> where type = feat|fix|docs|style|refactor|test|chore|perf. Subject: 50 chars max, imperative mood ("add" not "added"), no period. For small changes: one-line commit only. For complex changes: add body explaining what/why (72-char lines) and reference issues. Keep commits atomic (one logical change) and self-explanatory. Split into multiple commits if addressing different concerns.

## Tools

- Use rg instead of grep, fd instead of find for spee for speed
- tree is installed; use this instead of find if you need a brief repository overview

When running inside Herdr, preview images with `kitten icat /absolute/path/to/image.png` in an ordinary shell pane on the host containing the image.
