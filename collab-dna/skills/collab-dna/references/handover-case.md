# The handover that became a port

A short case, anonymised, from the sessions these principles come from.
It is here because the lesson is not "the engineer was slow". The
review said the opposite. The lesson is that direction drift is
invisible to a green harness, that the shape of a plan drives the
behaviour of whoever executes it, and that prose can outrun product
while every gate passes.

## What happened

**Evening one.** A lead and Claude Code design a re-platform of a live
consumer product: a legacy Django app with a few thousand members,
moving to a Next.js web app, a Node API, a new Postgres with a
first-principles schema, and a migration done as one rehearsed cutover
after side-by-side parity testing. In about three hours they produce
the architecture RFC, the domain-model RFC, an inventory of the legacy
with keep/adapt/drop verdicts, a glossary, and a plan of eleven slices
with acceptance criteria. The plan is written as a handover: someone
who was not in the room will execute it. The lead's instruction for the
team shape is one line: "push as much as possible and just get back to
me when there's a fully ready to test environment."

**Days two to four.** An engineer takes the plan and, with an agent,
lands thirty commits: slices one through nine of eleven, each with a
recorded acceptance run, five hundred tests, seventy end-to-end tests,
and a parity harness replaying eighty-one requests against both stacks
with zero differences. Under three days.

**Day four, afternoon.** The lead, expecting a testable environment a
day earlier, opens a session: "My take is that they overengineered the
build ... and they lollygagged." He asks for an independent review.

## What the review found

The review was done on a machine that had never run the project, with
three read-only code passes. Its verdict, kept in writing:

- **Pace: fast, not slow.** The plan had sized those nine slices at
  roughly ten engineer-weeks. They took under three days. The plan's
  sizing was wrong by about five times, and "the sequencing was
  followed more faithfully than it deserved."
- **Proportion: lean code, heavy prose.** No abstraction with a single
  caller, no stubs, zero TODOs. What was large was verification and
  documentation: a 589-line acceptance log and about 1,100 lines of
  follow-ups per batch.
- **Direction: a port, not a rebuild.** The plan said: a component
  library on a headless UI layer, the legacy design tokens as the
  theme, the legacy's hand-rolled overlay shell and 9,000 lines of
  vanilla JS dropped with their behaviour kept as tests. What landed:
  3,064 lines of the legacy stylesheet transliterated into the new
  app, hand-built dialog, overlay, tabs and drag components, no
  component library, and the legacy's architecture reproduced along
  with its pages: two view files over 900 lines, a profile page making
  up to forty sequential API calls to rebuild the old page shape. The
  parity harness was green *because* the old architecture had been
  reproduced.
- **Readiness: nothing deployed.** No hosting config, no staging, so
  the rule "staging gates production" could not be exercised. Sign-in
  would have failed on the first deployed environment (a bot-check
  secret required outside local, never minted by the form). The build
  needed a running API to pass.
- Plus a list of real defects, and a list of things done well: race-safe
  single-use tokens, database-level invariants including three the RFC
  had missed, an audit test that fails the suite if an admin route is
  unaudited.

The lead's opening prior, "overengineered and lollygagged", was not what
the evidence showed. The review recorded the evidence.

## The correction

Two commits, both prose. The first is the review. The second is a
directional correction, twelve lines, of which the load-bearing one is:

> The bar is identical UX and UI, proven by the design docs' state
> matrices and the parity harness; the means is our component layer,
> not the legacy's.

And on process:

> The plan's slices were a checklist that got treated as a schedule,
> and each one carried its own acceptance-log entry, follow-ups
> section, and parity rerun. Going forward: build everything, verify
> continuously against the harness, and hand back once.

**Day five.** The lead and the agent rebuild the web app's component
layer on the library, drop the no-JavaScript rule that had leaked from
the legacy ("a silly requirement all around in 2026, for both the app
and the admin"), restore parity to zero differences, add visual parity
at five viewports, stand up staging on both hosts with production data
loaded and verified, connect the repository so both deploy from main,
and write the team brief and the stakeholder summary. One day. The next
morning the whole team, including non-technical people, smoke-tests it.

## What to take from it

1. **Direction drift is invisible to a green harness.** Every gate the
   engineer had was passing. None of them could distinguish "same UX"
   from "same architecture". The check that catches it is a human
   asking, early, "is this being built the way we chose, or the way it
   was built?" (principle 4), and a provenance question for every
   inherited rule (principle 6).

2. **The plan's shape drove the behaviour.** Eleven slices, each with
   acceptance criteria, read as eleven gates. A conscientious engineer
   cleared them one at a time, with a log entry each. The plan's author
   had meant "build all of it, hand back once", and had even said so,
   but in a chat, not in the plan. The fix is upstream: plans with no
   time estimates, batches with exit gates, and "hand back once" written
   in the plan itself. The planning guide in the `harness` plugin
   (`references/agentic-planning.md`) exists because of this case.

3. **Prose outran product while every number looked good.** Five
   hundred tests and a 589-line log are not the same as a URL someone
   can open. "Deploy early" is not a slogan here; the first deployed
   environment would have failed sign-in, and nobody knew until a
   reviewer read the code.

4. **Let the evidence overrule the prior, in writing.** The lead's
   hypothesis was wrong about pace and right about direction and
   proportion. The review said so plainly and was committed. That is
   what made the correction credible to the engineer and reusable by
   the next one.

5. **The lead's own throughput is the calibration point, not the
   plan's.** "You and I would have done it in a couple hours, max" and
   "you say hours, but you normally accomplish them in minutes" are not
   bragging. They are the correct baseline for sizing agentic work, and
   the plan had used the wrong one.
