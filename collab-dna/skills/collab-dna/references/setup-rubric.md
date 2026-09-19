# Setup audit rubric

A session is shaped before the human types. The model answering, the
permission mode, the hooks, every CLAUDE.md in scope, the plugins and
MCP servers loaded into context, and what the project remembers between
sessions all decide how much the human has to do by hand. A setup that
prompts on every tool call, carries "ask before" rules from an old
project, and loads thirty skills into every session produces exactly
the profile a session audit flags as the human's fault: stops, retyped
rules, progress pokes, ceremony. Audit the setup before coaching the
person.

`scripts/inspect_setup.py` produces the inventory. Read it, then walk
the surfaces below. Every finding names the surface, the line in the
inventory, the effect on the loop, and the exact edit.

## The durable-home test

The sharpest input to a setup audit is a session audit's list of
repeated corrections and absent moves. Each one is a test case: does
it have a durable home in the setup (a numbered rule, a permission, a
hook, a memory, a command) or does it live in the human's typing? A
rule that never needs retyping usually has a mechanism behind it (a
setting, a hook); a rule that keeps being retyped usually has only
prose. Find the pairs and say which is which. That contrast is worth
more than any single finding below.

## Surfaces

Each surface opens with what good looks like, so that a clean surface
gets one confident line in the report rather than a hunt for something
to say. Most well-run setups come back clean on four of six.

### 1. Model and effort

**Good:** the strongest model the plan allows, pinned in settings,
matching the model that actually answered recent sessions; effort
high for design and review work; a delegation directive that says
which work goes to smaller models.

The inventory shows `model` and `effortLevel` from global settings and,
under "Recent sessions", the model that actually answered each session.
The second is the truth; settings can be overridden per session.

- **Sessions answered by a smaller model than the strongest available
  to the account.** A small model stops more, asks more, misjudges more.
  Half of what a session audit calls ceremony can be the human
  compensating for that. Say which model each audited session ran on
  and whether the coaching findings survive that discount.
- **`model` unset.** The default changes with releases; the human may
  not know what they are on. Pin the strongest the plan allows and say
  which (as of the audit; the names move).
- **`effortLevel` low or unset on complex work.** Effort is reasoning
  depth; for design and review sessions it should be high.
- **Subagents on a smaller model without a stated reason.** Fine for
  mechanical work, wrong for judgment. Check the delegation directive
  in CLAUDE.md says which is which.

### 2. Permission mode and rules

**Good:** a mode that lets the agent act without a prompt per tool
call, an empty or short `ask` list reserved for the irreversible, no
deny rules that fight the doctrine, and one source for the policy.
Say so in one line and move on.

`permissions.defaultMode` decides whether the agent runs or asks.

- **Mode unset or `default`.** Every tool call that is not on the allow
  list waits for the human. This alone produces hours of idle agent in
  a long build and turns the human into a click-through. For a trusted
  repo the mode should be the one that lets the agent act and reserves
  prompts for the dangerous tier (the names of the modes change; the
  inventory shows the current value, the audit says whether it prompts
  per call).
- **A short allow list on a prompting mode.** The human is approving
  `ls` and `git status` by hand. Either raise the mode or allow the
  read-only commands wholesale.
- **`ask` rules for routine actions.** Each one is a forced stop. Keep
  ask for the irreversible: production writes, deletes, deploys, money.
- **Deny rules that block the doctrine.** A deny on `git push` or on
  worktrees forces ceremony the human then types around.
- **Per-project `allowedTools` in `~/.claude.json` that contradict the
  settings file.** Two sources for one policy; the human does not know
  which wins.

### 3. Hooks

**Good:** few hooks, each a narrow guardrail on something irreversible
or a mechanism behind a rule that would otherwise be retyped; plugin-
supplied hooks known and wanted. The inventory lists user-defined
hooks and the enabled plugins that ship hooks separately.

Hooks run shell commands around tool calls and events. Each is either
a guardrail or a tax.

- **PreToolUse hooks that block or prompt broadly.** A guard that
  matches on a word ("git", "alias") rather than a command refuses
  legitimate work and forces workarounds. Name the hook, what it
  matched in the transcript, and the narrower pattern.
- **Stop or SessionEnd hooks that re-run gates or reviews every turn.**
  Fine at a gate, a tax between them.
- **Hooks left from another project** (paths that do not exist, tools
  not installed). Dead hooks fail silently or noisily; either is cost.
- **No hooks where one would remove a repeated correction.** If the
  session audit found "no pushes until I say so" typed four times, a
  PreToolUse hook on push is the durable form. Say so.

### 4. Instruction files in scope

**Good:** a short global file of standing directives with reasons, a
project file that routes (rules plus a table of where to look) in
under about a hundred lines, one intake (a `CLAUDE.md` alone, an
`AGENTS.md` alone, or a `CLAUDE.md` whose first line imports
`@AGENTS.md`), no ancestor files, no contradictions, and the operating
rules the session audit found retyped present as numbered rules.

Claude Code loads the global `~/.claude/CLAUDE.md`, every `CLAUDE.md`
(and `.claude/CLAUDE.md`) from the project's ancestor directories down,
the project's own, `CLAUDE.local.md`, and `.claude/rules/*.md`. All of
it is in context every turn. `AGENTS.md` is either-or by default: since
v2.1.277 Claude Code reads it only when no `CLAUDE.md`,
`.claude/CLAUDE.md`, or `CLAUDE.local.md` exists in the working
directory or above it (the **Project instructions** setting in `/config`
can change that to both, `claude-md-and-agents-md`). Read every file in
the inventory, and work out which ones the harness is actually loading;
the inventory's "AGENTS.md loading" line states which case applies.

- **An `AGENTS.md` that nothing reads.** Both files exist, the
  `CLAUDE.md` does not import `@AGENTS.md` and is not a symlink to it,
  and the setting is the default. The team's shared instructions are
  silent in every Claude session and nobody was told. Fix: make
  `@AGENTS.md` the first line of `CLAUDE.md`, or set
  `claude-md-and-agents-md`.
- **A personal `CLAUDE.local.md` shadowing the team's `AGENTS.md`.**
  The local file counts as a CLAUDE.md, so adding one to a repo that
  relies on `AGENTS.md` switches `AGENTS.md` off for that person only.
  Same fix.
- **A tool that created a `CLAUDE.md` in an AGENTS.md repo.** `/init`,
  a plugin installer, or a setup script wrote a small `CLAUDE.md` and
  shadowed the real instructions. Look at the file's commit history;
  move its content under an `@AGENTS.md` import.
- **AGENTS.md relied on where it cannot load.** Bedrock, Vertex, and
  Foundry sessions, sessions with hooks disabled, and the first session
  after an upgrade do not read `AGENTS.md` directly. The import is the
  portable form.

- **Rules that make stops the default.** "Ask before making changes",
  "confirm each step", "stop and report after every task", "open a PR
  for every change", "never commit without approval". Each is a
  ceremony rule. Quote it, name where it came from if you can tell, and
  give the replacement: the outcome-and-gate form ("build the whole
  slice, run its gate, stop once").
- **Rules for another project or stack in the global file.** A
  Django rule in the global file when the project is Next.js, a Linear
  workflow when the team uses nothing, a branch policy from a previous
  employer. Every one is context spent every turn and a chance of a
  wrong action. Move to the project that needs it or delete.
- **Contradictions between levels.** Global says commit to main;
  project says open PRs; a rules file says ask first. The agent picks
  one unpredictably and the human corrects it by hand. One rule, one
  home.
- **Missing standing directives the session audit asked for.** No
  delegation directive (which model for which work), no
  "flag time-sensitive training knowledge" directive, no push policy,
  no statement of who the reader of deliverables is. The audit's
  "write this down" items belong here; check whether they arrived.
- **Length.** A global file over about a hundred lines, or a project
  file that is an encyclopedia rather than a router, is a tax on every
  turn and dilutes the rules that matter. Say what to move to `docs/`.
- **Rules the harness now does unaided, or now fights.** "Take work
  as far as you can before asking" when the harness runs autonomously;
  "delegate freely" when the harness says spawn rarely; a manual
  worktree rule when isolation is built in. These are the prune pass's
  job: note them here, then run `supersession-rubric.md` for the
  evidence standard and the one-at-a-time report.
- **Rules that restate what the doctrine already says, badly.** A
  half-remembered "no time estimates" that still lets sprints through.
  Point at the harness planning block or the collab-dna principles.

### 5. Plugins, skills, MCP servers

**Good:** every enabled plugin earns its context on this project; no
two skills share a trigger; every MCP server is used by the work and
signed in. A large plugin for a stack the project actually deploys to
is fine; the test is use, not size.

Every enabled plugin's skill descriptions, every project skill, and
every MCP server's tool list load into context at session start. The
inventory lists them with counts.

- **Plugins for other stacks or clients enabled globally.** A
  35-skill deployment plugin on a project that does not deploy there.
  Disable per project or globally.
- **Skills whose descriptions trigger on everything.** "Use this
  liberally"; triggers on "plan", "review", "setup". Two such skills
  fight, and the wrong one loads. Name the overlap.
- **MCP servers with large tool surfaces that the project never
  uses.** Dozens of tool schemas per turn for nothing. Keep the ones
  the work touches; the rest are per-project or off.
- **Servers needing auth that is not set up.** They fail on every call
  the agent tries. Either authenticate or remove.
- **Nothing installed that the doctrine assumes.** No planning guide,
  no code-review skill for the supervised-batch pattern, no way to
  fan out. Say what to install.

### 6. Memory and repo docs

**Good:** a memory directory with an index and current entries, and
repo docs that hold the operating rules so nothing load-bearing lives
only in memory or chat.

- **No memory directory for the project.** Nothing is carried between
  sessions except the repo, so every session starts cold and the
  human retypes context. Fine if the repo docs are complete; check
  that they are.
- **Stale or wrong memory entries.** A memory that names a decision
  since reversed, or a file that no longer exists, misleads every
  session. Delete or correct.
- **Decisions reversed in practice, never superseded on the record.**
  The same rot in the repo's own docs: an ADR or spec still marked
  accepted while the code does something else, or a workaround built
  beside it. Every session that reads the record gets two truths. The
  fix is a superseding record, not an edit to the old one. The mirror
  finding: no instruction anywhere says how to treat old records, so
  agents either obey expired decisions or reopen live ones on taste.
  The standing directive is "past decisions are evidence, not
  commitments; reopen on failed premises or cheap reversal; one-way
  doors keep the old caution; supersede, do not work around".
- **Repo docs that do not hold the operating rules.** The session
  audit's repeated corrections ("same rules as always") are the test:
  if the rules are not in `CLAUDE.md` or the ways-of-working doc, the
  human will keep typing them.

## Report shape

```
# Setup audit: <project>

<one line: Claude Code version, model, effort, permission mode, count
of instruction lines in scope, plugins on, MCP servers, memory files>

## What is making stops the default
<findings from surfaces 2, 3, 4 that force the human into the loop;
each with the inventory line, the effect, and the exact edit>

## What is taxing every turn
<findings from surfaces 4 and 5: context spent on rules and tools the
project does not use; each with the edit>

## What is missing
<standing directives, hooks, memory, or plugins the doctrine assumes
and the setup lacks; each with the exact text or command>

## What is superseded
<rules the harness now does unaided or now contradicts; one line each
pointing at the prune pass for the evidence and the patch, or the
prune report itself if it was run>

## What the model lines say
<which model answered the recent sessions, whether it matches the
settings, and how much of the session audit's findings that discounts>

## What is fine
<surfaces that are set up well, one line each, so they are not
touched by mistake>

## Do this first
<up to three edits, in order of turns saved, each as the exact
change: the setting, the line to delete, the line to add; then one
line naming what just missed the cut and why>
```

## Tone

Same as the session audit: specific, quoted, no moralising. A bad
setup is usually inherited, not chosen; say what it costs and what to
change, not whose fault it is. Never print a secret, even masked ones
are better left out of the report. If the inventory shows the human
already has something right, say so; the point is to remove what is
not serving them, not to replace their setup with yours.
