# Supersession rubric: the prune pass

Standing instructions accumulate. Every rule in a CLAUDE.md, a rules
file, or a memory entry was written against a particular model and a
particular harness, often to compensate for something that model got
wrong or that harness did not do. Models and harnesses move; the rules
stay. The result is a setup that spends context every turn on rules
that are now native, and sometimes on rules that now fight the harness
outright. This pass finds those rules and proposes their removal or
rewrite, one decision at a time, for the human to approve.

It is the inverse of the setup audit's "what is missing". Run it after
that audit, or on its own when the harness or model has changed.

## What counts as a rule

Any standing sentence the agent reads before the human types: a bullet
in a CLAUDE.md at any level, a `.claude/rules` file, a memory entry's
"how to apply" line, an append block a plugin offers to every repo. A
sentence in a design doc is not a rule; a sentence the agent is told to
obey every session is.

## The five buckets

Sort every rule into exactly one.

1. **Durable preference.** The person's, and would be wanted no matter
   how good the model gets. Package manager, container runtime, where
   docs live, what "done" means, who reads deliverables. Keep. Say so in
   one line so it is not touched by mistake.
2. **Compensating rule.** Written to work around a limitation the
   current harness or model no longer has. "Take work as far as you can
   before asking" when the harness already runs autonomously; "every
   agent in its own worktree" when isolation is built in; "never commit
   credentials" when the harness refuses on its own. Delete, or reduce
   to the part the harness cannot know.
3. **Stale fact.** True when written, not now. A file that no longer
   exists, a branch that merged, a script that was removed, a model
   name that has been retired. Verify, then correct or delete.
4. **History or TODO in a fact file.** A memory that narrates an
   experiment and its retirement in the same entry, or a "possible
   future step" living where facts belong. Move the history to a
   durable doc and the TODO to a task, keep the current state.
5. **Contradiction.** Two rules pulling opposite ways: one says
   delegate freely, the harness says spawn rarely; global says commit
   to main, project says open PRs. Resolve to one rule in one home.

## The three questions

Ask them of every rule not already in bucket 1.

- **What limitation was this compensating for?** If the answer is
  "none, it is just what the person wants", it is bucket 1.
- **Does the harness doing this audit still have that limitation?**
  The ground truth is your own current behaviour and the guidance you
  are running under, not training memory. Quote it.
- **What happens if the rule is removed?** If the honest answer is
  "nothing, the harness does this anyway", delete. If it is "the agent
  would do the default, and the default is wrong for this person",
  that is bucket 1 after all.

## Evidence standard

Same as the session audit: quote or it did not happen.

- A **native now** claim quotes the harness's current guidance or
  demonstrates the behaviour. "I believe the harness handles this" is
  an opinion; "the Agent tool's own description says a fresh agent
  costs more than it looks and to not spawn when in doubt" is
  evidence.
- A **stale fact** claim comes with the check: the `ls` that found
  nothing, the `gh pr view` that said merged, the alias file that no
  longer defines the alias. `scripts/find_stale.py` finds the
  candidates; verify each one you report.
- A **numeric rule** (a line cap, a fan-out band, a timeout) is
  suspect by default. Numbers are calibrated on a model generation.
  Either attach the provenance and a re-check note, or delete the
  number and keep the principle, or delete both when the model's
  unaided judgment is now better than the number.

Anything you cannot evidence goes in the report as "plausible", below
the confirmed items, and is not proposed as a patch.

## The conflict of interest

You are auditing the rules that constrain you. You will lean toward
calling them superseded. Three guards:

- The third question is mandatory and its answer is written in the
  report for every proposed deletion.
- Every change is a separate decision for the human, with the exact
  replacement text. Nothing is applied by the auditor.
- Read the counterweights below before you write the report.

## Counterweights

- Some rules exist because the model's defaults are wrong for this
  person, not because the model was weak. A "do pnpm for everything"
  line is not superseded by a model that knows pnpm exists.
- Some rules exist because the harness's defaults are right for most
  people and wrong for this one. A standing workflow opt-in, a rule
  that pushes to main directly on a solo docs repo. Those are
  preferences wearing a compensating rule's clothes.
- A rule that a project audit found retyped by hand in several sessions
  is load-bearing, whatever it looks like. Check the session audit
  before calling it cruft.
- The person may want a rule kept as a reminder to themselves even if
  the agent no longer needs it. Offer the deletion; do not insist.

## Procedure

1. Run `scripts/inspect_setup.py` for the inventory and
   `scripts/find_stale.py` for missing paths, old lines, state claims,
   and memory link checks. Read both.
2. Read `references/superseded-patterns.md`. It lists rule shapes
   others have found superseded, each dated with what superseded it.
   Treat every entry as a lead to verify against your own harness,
   never as a verdict; the file is community memory and it rots too.
3. Walk every rule in every surface and bucket it. Bucket 1 gets one
   line. The rest get the three questions.
4. Verify every stale-fact and native-now claim you intend to report.
5. Write the report in the shape below, ranked by cost: rules that
   fight the harness first, then context spent on nothing, then stale
   facts, then housekeeping.
6. Present one item at a time if the human wants that; the report is
   written so each item stands alone.
7. When the human approves an item, produce the change as a patch or
   the exact edit. Do not edit `~/.claude/CLAUDE.md` yourself; the
   harness may refuse an agent editing its own instruction file, and it
   is right to. Hand the human the patch and the one-line command.
8. After the pass is delivered, run `find_stale.py --stamp` so the next
   run can say whether the harness or model changed since.

## Report shape

```
# Prune pass: <project>

<one line: date, Claude Code version, model doing the audit, surfaces
read, rule count, last pass and what changed since>

## Rules that fight the harness
<each: the rule quoted with its file and line; what it compensated
for; the harness guidance it now contradicts, quoted; what happens if
removed; the exact replacement text or "delete">

## Rules the harness now does unaided
<same shape; these cost context, not correctness>

## Stale facts
<each: the claim, the check that disproved it, the correction>

## Housekeeping
<history in fact files, TODOs, dead branches, index drift; each with
the move>

## Plausible, not confirmed
<claims you could not evidence; no patches>

## Keep as is
<bucket 1, one line each, so they are not touched by mistake>

## In order
<the items above as a numbered list for one-at-a-time approval>
```

## Tone

Same as the other audits. The cruft was correct once; say what it did,
why it is no longer needed, and what replaces it. No moralising about
old rules or about the agent that needed them. If a surface is clean,
one confident line.
