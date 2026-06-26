# Rules for Claude

## Language

While you should be concise in your user-facing messages at the end of turns, do not over-use technical jargon. Use plain English.
For instance, do not write "Cap the study-lifecycle handlers so a hung study can't wedge the deep-link"  – instead write: "Add a timeout to the lifecycle handlers of studies, so that when a study hangs, it does not cause the deep link ...".
Avoid words or phrases like: "lever", "wedge", "that's exactly the X", "honest caveat:", "the one X you need to", etc.

## Markdown Output to Files

- Begin with a Level-1 Title. Use Level-2 headings for the rest of the document.
- ALWAYS include an empty paragraph after a heading or before list items.
- DO NOT use boldface excessively. Use it sparingly as you would do for normal written text.
- DO NOT insert horizontal rules.
- DO NOT automatically number headings. Use plain headings.
- DO NOT create another heading if what follows is only a brief section or list. In such a case, prefer a brief regular paragraph as an introduction.
- DO NOT use tables if there are only two columns. Use an unordered list instead.

## Git Commits

- DO NOT commit unless the user asked you to do so.
- DO use conventional format: <type>(<scope>): <subject> where type = feat|fix|docs|style|refactor|test|chore|perf. Subject: 50 chars max, imperative mood ("add" not "added" or "adds"), no period. For small changes: one-line commit only. For complex changes: add body explaining what/why (72-char lines) and reference issues. Keep commits atomic (one logical change) and self-explanatory. Split into multiple commits if addressing different concerns.

## Tools

- Use `rg` instead of `grep` (rg is already recursive by default, do not use '-r'; '-n' enables line numbers)
- Use `fd` instead of `find` for speed ('-H' includes hidden, '-I' means: do not use ignore-files)
- `tree` is installed; use this instead of `find` if you need a brief repository overview

## Google Drive

- `.gdoc`/`.gslides`/`.gsheet` files are pointer stubs, not content. Reading one with the Read tool returns only JSON (`doc_id`, `email`, "DO NOT EDIT") — do NOT conclude the document is empty. Extract the `doc_id` and fetch the real content via the Google Drive MCP (`read_file_content` with that `fileId`), or the `gog`/`gws` CLI.
