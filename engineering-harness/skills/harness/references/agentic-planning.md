# Planning Work When Agents Do the Building

How to break down, sequence, and run a big piece of work when Claude Code
(or Codex, or any coding agent) is doing most of the typing. Read this
before you ask an agent for a plan, and hand it to anyone who's new to
working this way.

## Why the default plan is wrong

Models learned to plan from decades of human-paced software work. Ask one
to plan a feature and you'll get a 3-week, 5-phase roadmap with "Week 1:
setup and research," because that's what the training data looks like.

The estimate is wrong. We've watched a JetSmart site clone land in about
10 minutes, a Vaki frontend rebuild in an hour, and a production bug that
would've eaten a sprint get found and fixed the same afternoon. Those are
the baseline now, not the outliers.

The shape of the plan is wrong too, which matters more. A human-paced plan
bakes in constraints that no longer hold: one person, one thing at a time,
context switches are expensive, tests are costly to write, review is the
bottleneck. When agents build, the constraints are different: context per
agent is finite, shared state is dangerous, and human attention is the one
thing you can't parallelize.

So the plan has to be rebuilt around the new constraints, not just
compressed. That includes the order of work. Waterfall phases, team
handoffs, and the integration passes between them were answers to
staffing constraints, not properties of the work. Re-derive the sequence
from dependencies and shared state alone.

## The rules

### 1. No time estimates. Sequence and dependencies instead.

Never write duration, effort, sprint, or delivery estimates into a plan.
Describe what has to exist before each piece can start. If someone asks
"how long," the honest answer is "as many review gates as you can clear
today," and that's a question about the human's calendar, not the work.

If an agent hands you a plan with days or weeks in it, send it back.

### 2. Sequence by dependency and risk, nothing else.

For each unit of work ask two questions. What must exist before this can
start? What breaks if this is wrong?

Only the first question creates ordering. The second creates a review
gate. Don't confuse them: "risky" means a human reads the diff before it
lands, it doesn't mean it has to wait its turn.

A plan inherits past decisions (ADRs, specs, prior threads) as evidence,
not commitments. If a record's stated premises no longer hold, or
reversing it is now cheap, the plan may reopen it, and the first unit of
that work is the superseding record. Otherwise the burden is on the
change. Reopening a one-way door (data models, public contracts,
migrations) belongs to the risky tier: a human reads it before it lands.

### 3. Default to parallel. Serialize only what shares state.

Overlapping files, database migrations, the shared local database,
production data, anything irreversible: one task at a time. Everything
else fans out.

Serializing is a finding about the specific work ("these two both edit
the auth middleware"), never a default posture. If you can't name the
shared state, it isn't there.

### 4. Collapse phases into batches with exit gates.

The old plan had research, design, implement, test, and docs as separate
phases. The new plan has batches. A batch is a set of units that can run
at once, and it closes when its exit gate passes: verify green, behavioral
tests pass, a grep for the stale pattern comes back empty, a screenshot of
the flow exists.

A batch is a commit boundary, not a calendar boundary. Rollback
granularity is the commit.

Tests are cheap now. Before a refactor, have the agent write behavioral
tests against current behavior and keep them green through the change.
Skipping them is the expensive choice.

### 5. Size a unit by what one agent can hold, not by time.

A unit is right-sized when one agent can keep the whole spec in context
and nail it. When an agent gets "build the entire features section," it
glosses over details. When it gets one focused component with exact
values, it gets it right.

### 6. Foundation first, then everything at once.

Some things are genuinely sequential because everything else consumes
them: the schema, shared types, design tokens, an API contract. Build
those alone, verify, then fan out every unit that depends on them.

The common shape is db → api → web. Schema and query exports land and
build first. Routes and screens then run in parallel against the built
contract.

### 7. Fan-out.

Three or more independent units can fan out to parallel agents. Whether
they should depends on whether each unit needs its own context: a large
or noisy unit earns its own agent, while a handful of small units is
usually faster done serially in one context. For 1 or 2 units, do them
inline.

Fan-out is an opt-in in Claude Code. The harness only runs a multi-agent
workflow when the user has said so, in the session or in a standing
CLAUDE.md line. The band that worked in practice is 5 to 10 agents at
once; past about 12, agents backed off on shared rate limits and the
gains evaporated. That was measured on org-brain's 452-source bulk run;
re-measure before relying on it.

Isolation is the harness's job now. Each agent gets its own git worktree
and branch, and the orchestrator merges at the end with full context of
what everyone was asked to do. Confirm it is on; don't build it by hand.
Two agents on one branch is how work gets silently overwritten.

### 8. Measure progress in gates passed.

Not percent complete, not tasks checked. A plan with 3 batches and 3 gates
is done when 3 gates have passed. This is the only status that survives
contact with an agent that "finished" something that doesn't build.

### 9. Optimize for human attention. It's the scarce resource.

Few, batched review gates beat many small check-ins. Tell the agent to
take it as far as it can go before asking. Human review is for taste,
product judgment, and the risky tier (migrations, auth, money, deploy
config, prod-path dependencies). It is not for confirming the software
runs.

"It compiles" is not done. "Tests pass" is not done if no test drove the
product. The gate is the flow exercised against the running stack.

### 10. Give outcomes and context, not task lists.

"This is happening with these parameters, investigate what could cause
it" beats a 12-step checklist. Ask the agent for options and a
recommendation before you ask it to build. Treat it like a senior partner
who needs context, not a junior who needs instructions.

## The procedure

1. **Write the outcome and the non-goals.** The PRD template in this
   plugin does this. Non-goals stop scope creep for agents as much as for
   humans.
2. **Ask the agent for a dependency graph.** Use the prompt below. Forbid
   time estimates in the ask.
3. **Find the foundation.** Whatever everything else depends on is batch
   0. It runs alone.
4. **Find the shared state.** Migrations, prod data, the same file edited
   twice. Those units serialize. Name the state that forces it.
5. **Everything else is one parallel batch.** Cap each unit at what one
   agent can hold. Split until it fits.
6. **Write the exit gate for each batch.** Concrete and checkable.
7. **Run it.** One worktree per agent, which the harness provides,
   orchestrator merges, gate, next batch.
8. **Human eyes on gates and on the risky tier.** Nowhere else by default.

## Prompt to hand the agent

```
Plan the following work for agentic execution. Do not include any time,
effort, or duration estimates anywhere in the plan.

Outcome: <what should be true when this is done>
Non-goals: <what we are explicitly not doing>

Produce:
1. The dependency graph: which units must exist before which others.
2. Batch 0: the foundation everything else consumes (schema, types,
   contracts, tokens). Keep it as small as possible.
3. The units that must serialize, and the specific shared state
   (file, table, dataset) that forces each one.
4. Every remaining unit, grouped into as few parallel batches as the
   dependency graph allows. Size each unit so one agent can hold the
   whole spec; split anything bigger.
5. A concrete exit gate per batch (commands, tests, greps, screenshots).
6. The risky-tier units that need a human diff read before landing.

Then recommend which batch to start with and what you'd run in parallel.
```

## A worked example

"Add invite-only onboarding." The human-paced plan had 4 milestones over
3 weeks.

The agentic plan:

- **Batch 0** (serial, 1 agent): invite table, migration, shared types,
  query exports. Gate: package builds, migration applies clean locally.
- **Batch 1** (parallel, 4 agents in 4 worktrees): invite API routes,
  invite screens, email templates, behavioral tests for the flow. Gate:
  verify green, screenshots of the full invite → accept → land flow
  against the local stack.
- **Batch 2** (serial, human eyes): production migration and rollout.
  Gate: human reads the diff, migration runs, smoke check on prod.

Two gates a human has to clear. The calendar is whatever it takes to clear
them.

## Smells

- The plan has "week," "day," or "sprint" in it.
- Phases named research, design, implement, test, docs.
- One agent assigned "the entire X."
- Serialized "to be safe" with no shared state named.
- Fourteen check-ins for one feature.
- Two agents on the same branch.
- Progress reported as a percentage.
- A refactor with no behavioral tests written first.

## Where this came from

Pulled together from rules that were already in use across Katapult repos:
the ProCarmelita and dealership-platform "Estimation and execution" and
"Lightweight collaboration" sections, Sofia's no-estimates hard rule, the
clone-website skill's foundation-first dispatch, org-brain's measured
fan-out limits from a 452-source bulk run,
the Reflections cross-boundary team shape, and the Katapult Way sessions on
outcome-based collaboration. If you find a better rule in a repo, promote
it here.
