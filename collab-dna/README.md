# collab-dna

How we build with agents, captured as auditable moves.

One lead's way of working with Claude Code, distilled from the sessions
in which a platform re-architecture was designed, handed over, reviewed,
taken back, and shipped to a prod-like environment in a day. Sixteen
moves, each with the reason it matters and a verbatim example. Plus an
audit that applies them to any local session transcript, so an
engineer can see their own sessions the way that lead would.

## What it does

- **`/collab-dna:audit [latest | <session id> | <path>]`** — extracts
  a past Claude Code session from `~/.claude/projects/` and reports
  which moves were made, which were missed, what the misses cost (in
  turns, rebuilds, or wrong direction), the better move as a sentence
  you could have typed, and the one thing to write into CLAUDE.md so it
  never needs saying again. No argument lists your sessions to pick
  from.
- **`/collab-dna:audit project [--last N] [--since DATE]`** — the same
  across every session of the current project, worktree sessions
  included. This is the one to run for coaching: it finds the
  correction you typed in four sessions, the move you never make, and
  whether the last session was better than the first.
- **`/collab-dna:retro`** — the same audit of the conversation you are
  in. Good before a compaction or at the end of a long build.
- **`/collab-dna:setup-audit`** — inventories what shapes a session
  before you type (model, effort, permission mode, hooks, every
  CLAUDE.md in scope, plugins, MCP servers, memory), read-only and with
  secrets masked, and reports what forces stops, what taxes every
  turn, and what is missing. Run it before coaching anyone whose
  sessions look slow; an inherited setup produces the same profile as
  bad habits.
- **`/collab-dna:principles`** — the moves, one paragraph first, then
  the list.

Claude also picks the skill up on its own when you ask things like "how
could I have driven this better", "am I using you well", or "what went
wrong in that session".

## The moves, in one paragraph

Give the agent the outcome, the reason, and the future it must serve,
then let it derive the how. State constraints once with their reasons
and write them into the repo. Name the reader and the bar before the
work, not after. Carry only behaviour, look, and data from anything
legacy. Trust nothing by default, the agent's estimates and training
included, but accept good answers in two words. Ask where requirements
came from and whether numbers are real. Reopen methods while they are
working. Decide small things in one turn with a reason and track what
you defer. Spend effort on product and verify against the running
system; strip ceremony and schedule scaffolding for removal. Run the
agent on a long leash, pull for gates not progress, force a read-back
after a big miss, and be the fast hands for what only you can do. When
something goes wrong, fix the system that produced it, and tell the
people outside the session in their own register.

## What is in the box

```
collab-dna/
├── commands/
│   ├── audit.md          /collab-dna:audit
│   ├── retro.md          /collab-dna:retro
│   ├── setup-audit.md    /collab-dna:setup-audit
│   └── principles.md     /collab-dna:principles
└── skills/collab-dna/
    ├── SKILL.md
    ├── references/
    │   ├── principles.md          the sixteen moves, with evidence and counterweights
    │   ├── audit-rubric.md        procedure, stats signals, report shapes, tone
    │   ├── setup-rubric.md        the six setup surfaces and the setup report shape
    │   ├── annotated-session.md   a real three-day session, human turns only, moves labelled
    │   └── handover-case.md       the case the principles came from
    └── scripts/
        ├── extract_session.py     JSONL transcript → readable markdown + stats
        └── inspect_setup.py       read-only setup inventory, secrets masked
```

## How the audit reads a session

`extract_session.py` finds the transcript for the current project (the
directory name under `~/.claude/projects/` is the working directory
with `/` replaced by `-`; worktrees have their own, and `project` mode
gathers them), keeps the human's turns in full, shortens the assistant's turns to a preview, and drops
tool output, subagent notifications, and compaction summaries to one
line each. It prints a stats block (turns, words each way, questions
asked, commands the human ran, fan-out, compactions, span) and the
path of the markdown. Claude reads that, not the raw JSONL.

`project` mode does this for every session of the project, writes a
human-only extract alongside each full one, and builds an index with
per-session counts so the audit can find recurrence. Email addresses
and credentials in URLs are always redacted; `--redact Name,Name`
replaces people's names.

Every session and project report opens with the model that answered
the session and the model doing the audit, because both change what a
finding means. `extract_session.py list` shows the model per session.

The report is coaching, not grading: present / partial / absent per
move, then the two or three findings that cost the most, quoted, with
the better move in your own voice. No scores.

## Privacy

The extract is written to your temp directory and may hold client
names or things pasted by accident. The skill is told not to copy it
into a repo and not to quote credentials or third parties in the
report. Audit your own sessions.

## Related

The planning half of this way of working lives in the `harness`
plugin: `skills/harness/references/agentic-planning.md` covers how to
break down and sequence big work when agents build it. Read that
before a session; read this one after.
