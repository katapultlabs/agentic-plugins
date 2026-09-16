# Superseded patterns

Rule shapes people have found in their own setups that a later harness
or model made unnecessary, or turned against them. Each entry says what
the rule was for, what superseded it, when that was observed, and how
to verify it in the harness you are running now.

**Every entry is a lead, not a verdict.** The prune pass checks each
one against the live harness before reporting it. This file is
community memory, and it rots like any other rule file: an entry
observed against one version may be wrong against the next. When you
find one that no longer holds, fix the entry.

To contribute: one entry per rule shape, in the format below, by pull
request to katapultlabs/agentic-plugins. Quote the rule shape, not your
private text.

## Format

```
### <rule shape, quoted or paraphrased>
- Compensated for: <the limitation>
- Superseded by: <the harness or model behaviour>
- Observed: <date>, <harness and model>
- Verify: <what to look at in your own harness>
- Do: <delete | reduce to ... | rewrite as ...>
```

## Entries

### "Delegate freely to subagents for parallelism, cost, focus, speed"
- Compensated for: a time when spawning was the only way to get
  parallel hands and frontier-model turns were the cost to avoid.
- Superseded by: harness guidance that a fresh agent costs more than
  it looks, that briefs should be few and rich, and that a fork
  inherits full context; large fan-outs go through a workflow tool
  that needs the person's explicit opt-in.
- Observed: 2026-09-16, Claude Code 2.1.273, Fable 5.1.
- Verify: read the Agent tool's description in your own context for
  the cost and "when in doubt, don't spawn" language.
- Do: rewrite as what to delegate (noisy, context-heavy, unanchored
  review) and which model when you do; drop "freely".

### "Three or more independent units means parallel agents" (in a CLAUDE.md)
- Compensated for: models that planned serially by default.
- Superseded by: the same harness guidance; a standing spawn trigger
  in a repo's CLAUDE.md now either over-spawns or is blocked by the
  workflow opt-in rule.
- Observed: 2026-09-16, Claude Code 2.1.273, Fable 5.1.
- Verify: check whether a multi-agent workflow tool exists and what it
  says about opt-in.
- Do: keep "can fan out" as a planning principle in a long guide;
  remove the trigger from every-session instruction files; add a
  standing opt-in line to the global file if the person wants it.

### "Every agent works in its own git worktree; the orchestrator merges"
- Compensated for: agents sharing a branch and overwriting each other.
- Superseded by: worktree isolation built into the harness, enforced
  for background jobs and offered as an option on subagents.
- Observed: 2026-09-16, Claude Code 2.1.273, Fable 5.1.
- Verify: the Agent tool has an isolation option; background sessions
  are told to isolate before editing.
- Do: reduce to "confirm isolation is on"; delete the manual
  instructions.

### "Take work as far as you can before asking" / "few batched check-ins"
- Compensated for: agents that stopped to ask after every step.
- Superseded by: harness guidance to finish the whole task, reserve
  blocking questions for cases where any assumption would be unsafe,
  and act on reversible follow-ons without asking.
- Observed: 2026-09-16, Claude Code 2.1.273, Fable 5.1.
- Verify: your own autonomy guidance in context.
- Do: delete from every-session files; keep in guides written for
  humans, where it still teaches.

### "When something breaks: database errors → reset the local database"
- Compensated for: agents that did not know the project's recovery
  commands and stalled.
- Superseded by: harness guidance to check that evidence supports a
  specific state-changing action before running it, and to look at a
  target before deleting or overwriting. A standing "on error X, run
  destructive fix Y" is exactly the pattern match it warns against.
- Observed: 2026-09-16, Claude Code 2.1.273, Fable 5.1.
- Verify: your own guidance on state-changing commands.
- Do: delete the section; keep only repo-specific recovery commands
  that are non-obvious, phrased as "if the cause is X, the fix is Y".

### "Never commit credentials or .env files"
- Compensated for: agents that would stage anything.
- Superseded by: native refusal.
- Observed: 2026-09-16, Claude Code 2.1.273, Fable 5.1.
- Verify: attempt is refused without a rule.
- Do: delete from templates.

### A numeric cap calibrated on an older model ("~150 lines of spec per unit")
- Compensated for: models that glossed over details when handed a big
  spec.
- Superseded by: current models sizing units better unaided than the
  number does; the number itself was measured on one generation.
- Observed: 2026-09-16, Claude Code 2.1.273, Fable 5.1.
- Verify: hand the model a large spec and see whether it splits it
  sensibly without the rule.
- Do: delete the number, keep "one agent, one unit it can hold whole"
  if you keep anything.

### "Flag, don't fetch: never check a time-sensitive claim unless asked"
- Compensated for: web checks being slow or unavailable.
- Superseded by: search and fetch being one cheap tool call. The rule
  now produces hedged answers where a check would have produced a
  fact.
- Observed: 2026-09-16, Claude Code 2.1.273, Fable 5.1.
- Verify: WebSearch or WebFetch available in your tool list.
- Do: rewrite as "check when one call settles it, flag when it would
  be an investigation, always check before an irreversible action".

### A memory entry that narrates a retired setup next to the live one
- Compensated for: nothing; this is drift, not compensation.
- Superseded by: nothing; it is a rot pattern. The entry describes
  scripts, aliases, or services as live two bullets before saying
  they were removed.
- Observed: 2026-09-16.
- Verify: `ls` every path the entry names.
- Do: keep the current state, compress the retirement to one sentence,
  move the history to a durable doc.

### A memory entry that points at a branch or draft PR
- Compensated for: nothing; it was accurate when written.
- Superseded by: the merge.
- Observed: 2026-09-16.
- Verify: `gh pr view` and `git branch --merged`.
- Do: rewrite to point at main; if everything else in the entry is now
  recorded in the repo, delete the entry and keep only the one rule
  the repo cannot hold.

### "Possible future step: ..." inside a memory fact file
- Compensated for: nothing.
- Superseded by: nothing; a TODO in a fact file is never read as a
  TODO.
- Observed: 2026-09-16.
- Do: move to a task or a notes doc, or delete.
