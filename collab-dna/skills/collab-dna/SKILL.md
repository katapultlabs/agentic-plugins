---
name: collab-dna
description: "How we build with agents, captured as auditable moves. Use this whenever someone wants to get better at working with Claude Code or any coding agent: 'audit my session', 'review how I worked with you', 'retro on this conversation', 'how could I have driven this better', 'what should I improve in how I prompt', 'grade my collaboration', 'look at my last session', 'why did this take so many turns', 'am I using you well', 'show me the principles', 'how does our lead work with Claude', 'audit my setup', 'check my CLAUDE.md', 'is my harness slowing me down', 'why does Claude keep stopping to ask me', 'what plugins and rules am I carrying', 'prune my CLAUDE.md', 'which of my rules are outdated', 'what here is cruft', 'clean up my memory files', 'we upgraded models, what should change in my setup'. Also use it when a session has just ended badly (rebuilt artifacts, many corrections, wrong direction held too long) and the human asks what went wrong, even if they do not say 'audit'. Do not use it for code review; it reviews the human's moves, not the code."
version: 0.4.0
allowed-tools: Bash, Read, Glob, Grep
---

# collab-dna

The way one experienced lead builds with Claude Code, distilled from
real sessions into sixteen moves, with an audit that applies them to
any transcript. The purpose is to help an engineer see their own
sessions the way that lead would, and to hand them the specific
sentence they could have typed instead.

What this skill does:

1. **Audit a past session, or a whole project.** Extract a local
   Claude Code transcript (or every transcript for the current
   project), read the human's turns, and report which moves were made,
   which were missed, what the misses cost, and what to write down. A
   project audit finds what one session cannot: corrections typed in
   several sessions, moves never made, drift over time.
2. **Retro the current conversation.** Same audit, no extraction; the
   transcript is already in context and you were the agent.
3. **Audit the setup.** Inventory everything that shapes a session
   before the human types (model, effort, permission mode, hooks, every
   CLAUDE.md in scope, plugins, MCP servers, memory) and report what
   forces stops, what taxes context, and what is missing. Do this
   before coaching a person whose sessions look slow: an inherited
   setup produces the same profile as bad habits.
4. **Prune the rules.** Find standing rules in every CLAUDE.md, rules
   file, and memory entry that the current harness or model has
   superseded, and propose their removal or rewrite one decision at a
   time. Rules are written against a model and a harness; both move
   and the rules stay. Run it after a setup audit, or whenever the
   model or harness has changed.
5. **Show the principles.** The sixteen moves with their reasons, for
   reading before a session rather than after.

## Files

| File | What it holds | Read it when |
| --- | --- | --- |
| `references/principles.md` | The sixteen moves, each with a verbatim example, the reason it matters, and its audit question; the counterweights; a one-paragraph version | Always, before any audit or retro |
| `references/audit-rubric.md` | The procedure, what the stats block signals, the fixed report shape, and the tone | Before writing any audit report |
| `references/supersession-rubric.md` | The prune pass: five buckets, three questions, the evidence standard, the auditor's conflict of interest, the report shape | Before any prune pass |
| `references/superseded-patterns.md` | Rule shapes others found superseded, each dated with what superseded it and how to verify; leads, not verdicts | During a prune pass |
| `references/annotated-session.md` | A real three-day session, the human's turns only, each labelled with its move | When the human asks what a strong session looks like, or when you need a reference for a move you are about to call absent |
| `references/handover-case.md` | The case the principles came from: a handover that drifted into a port while every gate passed | When the audit touches legacy work, plan shape, or "fast but wrong direction" |
| `references/setup-rubric.md` | The six setup surfaces, what a bad one looks like on each, the edit, and the setup report shape | Before any setup audit |
| `scripts/inspect_setup.py` | Read-only inventory of the setup surfaces, secrets masked, plus the model behind each recent session | For any setup audit |
| `scripts/extract_session.py` | Turns a Claude Code JSONL transcript into readable markdown plus a stats block; `project` mode does every session of the project into a directory with an index | For any audit of a past session or a project |

## Auditing a past session

Claude Code keeps every session under `~/.claude/projects/<slug>/`,
where the slug is the working directory with `/` replaced by `-`. The
script knows this; you do not need to find the file by hand.

1. If the human did not say which session, list them and let them pick:
   ```
   python3 <skill-dir>/scripts/extract_session.py list
   ```
   Add `--all` to list every project. Newest first; each row is the
   session id, start time, number of human turns, size, and project.
2. Extract:
   ```
   python3 <skill-dir>/scripts/extract_session.py extract latest --stats
   ```
   `latest` picks the newest session with human turns in the current
   project. A session id prefix or a full path also works. The script
   prints a JSON stats block and then the output path. Read the output
   file; it holds the human's turns in full and the assistant's turns
   as short previews.
3. Read `references/principles.md` and `references/audit-rubric.md`.
4. Follow the rubric's procedure and produce the report in its shape.

The extract is the human's side of the conversation. Tool calls, tool
results, subagent transcripts, and pasted command output are removed
or reduced to one line. That is deliberate: the audit is of the
human's moves, and the assistant's behaviour matters only as evidence
of what those moves caused.

If the script finds nothing, the session may have run from a different
directory or on another machine. `list --all` shows everything on this
machine. Sessions run from git worktrees of the current checkout have
their own slug but belong to the project; `project` mode includes
them, `list` does not.

## Auditing a whole project

```
python3 <skill-dir>/scripts/extract_session.py project [--last N] [--since YYYY-MM-DD]
```

Writes two extracts per session (full, and the human's turns only)
and an `index.md` with a per-session stats table into a temp
directory, prints sizes to stderr, and prints the index path. Add
`--redact Name,Name` to replace colleagues' names. Read the index and
the human-only files, then follow "Auditing a whole project" in
`references/audit-rubric.md`: read every extract when there are a
handful, fan out one subagent per session when there are many, and
synthesise into the project report shape. The project report's value
is recurrence: the same correction in several sessions is a standing
instruction that was never written, and a move absent everywhere is a
blind spot.

## Auditing the setup

```
python3 <skill-dir>/scripts/inspect_setup.py --out <temp file>
```

Read the inventory, then `references/setup-rubric.md`, and produce the
setup report. Change nothing; the human applies it. When a session
audit already exists for the project, its repeated corrections and
absent moves are the test cases: each should have a durable home in
the setup (a rule, a hook, a permission, a memory) or the report says
it does not.

## Pruning superseded rules

```
python3 <skill-dir>/scripts/inspect_setup.py --out <temp file>
python3 <skill-dir>/scripts/find_stale.py --out <temp file>
```

Read both, then `references/supersession-rubric.md` and
`references/superseded-patterns.md`, and produce the prune report.
The inventory is every rule in scope; the stale scan is the
deterministic half (missing paths, old lines, state claims, memory
drift, what changed since the last pass). The judgment about which
rules are superseded is yours, made against the harness you are
running in, with its guidance quoted as evidence. Change nothing; hand
the human patches one item at a time, and never edit the global
CLAUDE.md yourself. Stamp the pass afterwards with `--stamp`.

## Retro of the current conversation

No script. Read the two reference files, then apply the rubric to the
conversation so far. You were the agent, so be as honest about where
your own output pulled the human off course as about the human's
turns; the rubric's last section says how.

## Showing the principles

Print the one-paragraph version at the end of `references/principles.md`
first, then offer the full list. If they want the full list, give the
sixteen move titles with their audit questions, not the whole file;
point them at the file for the examples.

## What to be careful about

- **State the models.** Both audit shapes open with the model that
  answered the session and the model doing the audit. A small model on
  either side changes what the findings mean; the reader has to be
  able to discount.
- **Quote or it did not happen.** A finding without the human's words
  and a turn number is an opinion. The rubric says this; it bears
  repeating because the temptation to summarise is strong.
- **Coaching, not grading.** No scores. Present / partial / absent per
  move, and then the two or three findings that cost the most, with
  the better move as a sentence in the human's own voice.
- **These are moves, not a checklist.** A session that made twelve of
  sixteen moves and rebuilt an artifact twice has one finding that
  matters, not four. Rank by cost, not by count.
- **The lead's way is a reference, not a template.** The principles
  file has a section of counterweights, places where the lead's own
  habits cost something. An audit that only measures distance from the
  lead has missed the point of the fifth principle.
- **Do not moralise about the agent.** If the agent added ceremony,
  guessed wrong, or ran long, the finding is what the human's
  instructions made possible, and the fix is an instruction.
- **If the session is one the principles quote from,** say so in the
  report. The finding is still real; the reader just should know the
  reference and the subject overlap.
- **The prune pass audits the rules that constrain you.** You will
  lean toward calling them superseded. The rubric's third question,
  what happens if the rule is removed, is mandatory for every proposed
  deletion, and the human approves each one. A rule that looks like a
  workaround may be a preference; the counterweights section says how
  to tell.
- **Private material stays private.** The extract may hold client
  names, credentials pasted by accident, or other people's words. It is
  written to the temp directory. Do not copy it into a repo, and do
  not quote credentials or third parties in the report.

## Related

The planning half of this way of working, how to break down and
sequence a large piece of work when agents build it, lives in the
`harness` plugin's `references/agentic-planning.md`. The two are meant
to be read together: that one shapes the plan before the session, this
one shapes the session and reviews it after.
