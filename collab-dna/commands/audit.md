---
description: Audit a past Claude Code session, or every session of the current project, against the collab-dna moves — which were made, which were missed, what they cost
allowed-tools: Bash(python3:*), Read, Glob, Agent
---

Audit a past session or a whole project. The argument, if any, is one
of `latest`, a session id or id prefix, a path to a `.jsonl`
transcript, or `project` (optionally followed by `--last N`,
`--since YYYY-MM-DD`, or `--no-worktrees`). With no argument, list the
sessions for the current project and ask whether they want one of them
or the whole project.

## One session

Follow the collab-dna skill's "Auditing a past session" section:

1. Locate the skill directory (this plugin's `skills/collab-dna/`).
2. If no target was given, run
   `python3 <skill-dir>/scripts/extract_session.py list` and show the
   rows. Ask the human to pick one; do not guess. Suggest `--all` if
   the list is empty, since worktrees have their own slug.
3. Run `python3 <skill-dir>/scripts/extract_session.py extract <target> --stats`.
   It prints a JSON stats block to stdout and, on the last line, the
   path of the markdown extract. Read that file. `--human-only` drops
   the assistant's text; `--redact Name,Name` replaces names.
4. Read `<skill-dir>/references/principles.md` (the audit questions are
   indexed at its end) and `<skill-dir>/references/audit-rubric.md`.
5. The extract lands in the temp directory and may hold client names
   or things pasted by accident. Do not copy it into a repo, and do not
   quote credentials or third parties in the report.
6. Produce the report in the rubric's exact shape. Quote the human at
   every finding with the turn number. Rank findings by cost. End with
   the one thing to write down and three lines for next session.

## The whole project

When the argument is `project`:

1. Run `python3 <skill-dir>/scripts/extract_session.py project`
   (pass through any `--last`, `--since`, `--no-worktrees`; add
   `--redact Name,Name` if the human wants colleagues' names replaced
   with `<name>`; `--out DIR` chooses the directory, default is a
   folder in the temp directory). It writes two files per session,
   `<id>.md` (full) and `<id>.human.md` (the human's turns only), plus
   `index.md`, prints one line per session with its size to stderr,
   and prints the index path last. Sessions run from git worktrees of
   the same checkout are included; they are the same project.
2. Read `index.md`, then `<skill-dir>/references/principles.md` and
   the "Auditing a whole project" section of
   `<skill-dir>/references/audit-rubric.md`.
3. Read the `.human.md` files first; they are a fraction of the size
   and hold everything the audit is about. Open the full extract only
   where you need to see what a human turn caused. Up to about six
   sessions, or fewer when the sizes on stderr are large, read them
   yourself. Beyond that, fan out one subagent per session with the
   two reference files and the single-session report shape, ask each
   for the moves table and findings only, and synthesise. Do not hold
   many transcripts in one context.
4. Produce the project report in the rubric's project shape: habits
   across sessions, repeated corrections, trajectory, findings ranked
   by project-wide cost, and the standing instructions to write.

Keep a single-session report around 1,200 words and a project report
around 2,000. In the project habits table, rows where every session
agrees may collapse to one line each. The moves table and the three
findings are the load-bearing parts; if something has to shrink, shrink
the arc and the keep-doing section, never the quotes. The human should
be able to read it in five minutes and act on it in the next session.
