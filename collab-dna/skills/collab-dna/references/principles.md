# How we build with agents: the moves

Distilled from the sessions in which a lead and Claude Code designed a
platform re-architecture, handed it over, reviewed the result, took it
back, and shipped it to a prod-like environment in a day. Every move
below is something the lead actually did, quoted from the transcript
(client and people names removed). Each one carries the reason it
matters and the question the audit asks about it.

Read these as moves, not rules. The point of a move is the effect it has
on the work; if you can get the effect another way, do that.

The moves fall into four groups: what you feed the agent (direction),
how you treat what comes back (judgment), where effort goes
(proportion), and how you run the loop (operating).

---

## Direction: what you feed the agent

### 1. Open with the outcome, the why, and the future it must serve

> "we just signed the partnership so that we can help [the client] build
> their digital products ... we want to migrate the front end to Next.js
> ... eventually we're also thinking about mobile apps where we want to
> also share profiles and auth ... so it makes sense to also think about
> an API from the get go ... Does that make sense? Let me know if you
> have any questions."

The first message is the highest-leverage message of a session. It sets
the altitude everything else is derived from. The lead names the goal,
the constraints already decided, the future the design has to survive
(mobile, shared auth), and invites questions. Nothing about *how*.

An agent given an outcome and a horizon will make a hundred small
decisions consistently with them. An agent given a task list will make
them arbitrarily.

**Audit:** Did the first substantive turn state the outcome and the
reason, and name any future the work has to serve? Or did it start with
a task?

### 2. State the operating constraints once, then write them into the repo

> "the repository should be fully self contained, and we should document
> anything important for future collaboration inside of the committed
> repository and not just in the local memory ... keep it simple with
> worktrees and branches but committing to main and moving fast ... we
> will likely want to have a staging environment because we already have
> production users"

Second message, and it becomes `ways-of-working.md` an hour later. The
constraints are process (light), collaboration (repo is the memory),
and safety (staging because real users exist). Each has its reason
attached, which is what lets the agent apply them to situations the
lead never mentioned.

The tell of a constraint that was stated well: it never has to be
stated again. The tell of one stated badly: the same correction appears
in three sessions.

**Audit:** Were constraints stated with reasons, and did they land in a
committed file or a CLAUDE.md, or did the same correction recur?

### 3. Name the reader and the bar

> "so that someone can come in and understand what's been done so far"

> "part of this refactor is having a really good starting point with an
> impeccable architecture for us to start building a wonderful set of
> products"

> "the work that you and I are doing here with this plan is something
> that we're going to hand over to someone else on our team"

The quality bar is defined by an absent third party, not by the lead's
own comprehension. "Document it" and "document it for a stranger who
was not in the room" are different jobs, and only the second is
checkable. The same goes for "an impeccable foundation for a family of
products": that bar rejects a faithful port before anyone has written
one.

Naming the reader late is the most expensive omission in these
sessions. In one review session, the page was rebuilt twice before the
lead said the reader was a non-technical stakeholder.

**Audit:** Was the audience of each deliverable named before it was
built? Was the bar stated as something an outsider could check?

### 4. Carry only behaviour, look, and data from a legacy; re-derive the rest

> "The frontend should be a complete refactor into our stack vs.
> bringing over the old frontend architecture/tech/patterns."

> "That's why it's so important we refactor into the technologies we
> chose from first principles, only functionality, UX/UI, data in order
> to have a wonderful foundation on top of which to continue building."

> "[the prior project is] a prior, not a template."

A legacy system contributes what users see and what they own. Its
architecture, its conventions, its tests, and its rules ("works without
JavaScript") are up for re-derivation. Legacy patterns dressed as "same
UX" quietly re-import the old architecture, and a green parity harness
cannot tell the difference. This is the correction that mattered most
in the handover case (see `handover-case.md`).

**Audit:** When a legacy or a prior project was in play, did the session
distinguish "what to match" from "how it was built"? Did any legacy
pattern leak into the new stack unchallenged?

---

## Judgment: how you treat what comes back

### 5. Trust no source by default, the agent included

> "the person that was leading the engineering is a designer by trade,
> so we also need to take that with a grain of salt ... think for
> ourselves what is worth keeping"

> "Again, you don't know how to estimate those things. You say hours,
> but you normally accomplish them in minutes."

> "Again, your knowledge is stale :)"

Three sources, three calibrations: the legacy repo's conventions, the
agent's estimates, the agent's training. None is dismissed; each is
weighted. The estimate correction is the one most people miss. Models
plan at human pace because that is what they learned from; when the
plan says "a week", read "an afternoon" and rebuild the shape of the
plan, not just the number.

The complement: when the answer is good, accept it in two words. "Like
it." "Yes, please." "Yes, make it so." Skepticism that never resolves
is just friction.

**Audit:** Did the human challenge at least one recommendation,
estimate, or fact? Did they accept good answers quickly, or re-litigate?

### 6. Ask for provenance before you accept a requirement

> "What's the no-JS requirement? And where did it come from?"

> "What did we do with the legacy admin?"

> "We say 'an album with 900 reviews' which makes a lot of sense
> hypothetically. Do we have that problem today?"

"Where did it come from" surfaced a rule that had been carried from the
legacy into the rebuild and extended to the admin, then killed it in one
line ("That's a silly requirement all around in 2026"). "Do we have that
problem today" turned a plausible illustration into an observed fact
(it was real, with numbers). Both are cheap questions with outsized
effect, and both are the kind an agent will not ask itself about its
own output.

**Audit:** When a requirement, number, or pattern appeared, did the
human ask where it came from or whether it was real? Or did plausible
things pass?

### 7. Reopen tools and methods from first principles, mid-flow

> "Wait - is playwright the right tool to be using? We can rethink
> everything from first principles."

> "Why not use Chrome?"

> "So, from first principles, how do we now confirm and find any UX/UI
> issues with this combo? Are we also doing a full responsive pass?"

The build was mid-run and going well. The lead still stopped to ask
whether the verification method was the right one, and whether the
coverage was complete. Momentum is not evidence of direction. The
pattern is a sequence: question the tool, propose an alternative, then
widen to "what are we not checking".

**Audit:** Did the human ever question a method or tool while it was
working, or only when it failed?

### 8. Decide fast, with the reason, and track what you are not solving

> "I think it's fine that members have to sign in once more at cutover,
> that is to be expected, and I think it's a low cost, we just have to
> make sure that we tell the product owner. So that's going to be the
> decision. We should also track the fact that the light palette fails
> the contrast, which is fine. The railway login, don't worry about it."

Three open items, three dispositions, one turn: decided with a reason
and an owner to inform; tracked and explicitly accepted; deferred to
the person who will own it. None of them became a discussion. The
reason travels with the decision so it can be recorded and, later,
revisited on evidence rather than memory.

The same session shows the reverse: a decision the lead did not make
("which auth provider") was asked as a question, answered with a
recommendation, and then decided. Options are for the things the human
genuinely has not decided.

**Audit:** Were small decisions made in one turn with a reason? Did
deferred items get tracked somewhere durable, or just dropped?

---

## Proportion: where effort goes

### 9. Product over prose; verify against the real thing

> "Build the whole thing as much as possible, then boot up both
> environments and peg them against each other to make sure we have
> parity. No need to unit test every micro decision."

> "The team shape, I don't know why we need to document that. I want him
> to push as much as possible and just get back to me when there's a
> fully ready to test environment."

The review of the handed-over build found "lean code, heavy prose": a
589-line acceptance log and a thousand lines of follow-ups per batch,
while nothing had been deployed. The lead's counter-move is to build
everything, then verify the whole against the running system (both
stacks side by side, request replay, screenshots at five viewports).
Tests that drive the product stay; ceremony that records the process
goes.

This is not "no tests". The same lead wrote, elsewhere, that behavioural
tests before a refactor are the cheap choice. The line is between
verification that exercises the product and prose that describes the
work.

**Audit:** What proportion of the session's output was product versus
description of product? Was the verification gate "the flow runs
against the real stack" or "the log says it passed"?

### 10. Strip the ceremony the agent adds defensively

> "I have write access. Just push to main, don't open a PR."

> "There's no need to create a PR for this. We can just land it on
> prod-like without fanfare."

Agents default to caution: a PR instead of a push, a plan review before
work, a confirmation before each step. Each one is a round-trip that
costs the human's attention, the one resource that does not scale. The
lead removes them on sight, and when the same one recurs, writes the
rule down so it stops recurring. (In one session the PR detour cost 80
minutes of wall-clock for work finished in 20; the fix was one line in
CLAUDE.md.)

**Audit:** Did the agent add process the human then removed? Did the
removal get written down, or will it recur?

### 11. Plan for the scaffolding to leave

> "we don't want this to run nightly in CI forever because we're going
> to switch over hopefully sometime next week, so we should also plan
> for leaving the pass behind without carrying performance or process
> baggage."

A parity harness, a legacy container, a data seeder, hooks that exist
only for a migration: all of it is scaffolding. Scaffolding that nobody
scheduled for removal becomes architecture. The lead asks for the
retirement schedule while the scaffolding is still being built, which
is the only moment anyone still knows what it was for.

**Audit:** Was anything temporary created? Does it have a recorded
removal condition?

---

## Operating the loop

### 12. Long leash, periodic pull, and delegation enforced

> "keep going, ping me when parity is done"

> "How we looking? It's been a long time"

> "Remember the global delegation rules"

The lead lets the agent run for hours and checks in with three words.
Review is spent on gates (parity done, staging up), not on progress.
When the agent forgets to fan out work to smaller models, one line
restores it. Attention goes where judgment is needed: direction,
taste, the risky tier. Nowhere else by default.

**Audit:** How many human turns were check-ins on progress versus
decisions? Did the human confirm that the software runs, or let the
gate do it?

### 13. Separate alignment from action when the miss is big

> "No, I didn't express myself well. The page, the artifact that we're
> creating should be all of the changes that we want to make ... it's
> pointless to document the changes that we've made ... Does that make
> sense? Don't change anything. Let's just be sure that we're on the
> same page."

> "Don't do anything that's just chat."

When a deliverable turns out to have the wrong premise, the instinct is
to describe the right one and let the agent rebuild. The lead instead
forces a read-back first and forbids action until it lands. One cheap
turn prevents a second wrong artifact. Note also the ownership: "I
didn't express myself well", not "you got it wrong".

**Audit:** After a large correction, was alignment confirmed before
rework started? Or did the second attempt also miss?

### 14. Be the fast oracle and the hands for what only you can do

> "Domain is https://www.[client].net/"

> "I installed both GitHub apps, but also connected them to the
> repository, however I didn't do any other configuration ... assume
> that I only did the initial configuration ... everything else is
> missing."

> "I was at the page, requested the link, went to my email, copied the
> link, went back to the browser, was on the same tab, and then I pasted
> the link in that same one, pressed Enter, and nothing happened, and
> then I opened a new tab, pasted the login link from the email, and
> then that one did log me in, but it took me to an account creation
> flow."

Facts only the human holds get answered in seconds. Steps only the human
can take (installing an app, running a gated command, testing with a
real inbox) get taken, and then reported with exactly what was and was
not done. The bug report above is precise enough to reproduce without a
follow-up question. The human is not a reviewer of the agent's work
here; they are a participant with a different set of hands.

**Audit:** When the agent was blocked on something only the human could
do, how fast was the unblock, and how precise was the report back?

### 15. Fix the system, not the instance

> "What's the most effective and efficient directive for the global LLM
> directive on not trusting the training for when recommending versions
> or solutions? ... But better :)"

> "I like that. What I want to prevent is unnecessary and expensive
> extra work; just the notification and suggestion."

> "What's the most effective and token-efficient version of this?"

> "Yes, make it so."

> "We're about to compact. Anything we should do in terms of
> documentation or else before that so a cold session can be as
> effective as us?"

The agent recommended a stale option. The lead did not just correct the
option; he asked for the standing directive that prevents the class of
error, iterated it twice (scope it down, make it cheap), and installed
it globally. Four turns, permanent effect. The compaction question is
the same move applied to memory: what does the next session need that
only this one knows?

This is the move that compounds. Everything else in this list is a
better session; this one makes every future session better.

**Audit:** Did any correction in the session become a durable
instruction (CLAUDE.md, a memory, a doc)? Or does it live only in the
transcript?

### 16. Communicate outward from the work, in the right register

> "Give me a concise executive summary to post to the team on this
> progress"

> "Also, give me an executive summary for our non-technical stakeholders"

> "I would caution against saying an architecture that *will* work for
> the next couple of years, instead saying *should*."

> "if I'm a non technical stakeholder ... I don't know why these things
> are important ... otherwise it just reads like a bunch of improvements
> for the sake of technical improvements"

The agent's summary is raw material for messages to people who were not
in the session. The lead asks for each audience separately, corrects
overclaims ("will" to "should"), and rejects a correct list on register
alone when it would not land with its reader. Then: "make it markdown in
/tmp so I can pbcopy it".

**Audit:** Were outward messages produced per audience, and were claims
calibrated? Did the human edit for the reader or just forward?

---

## The counterweights

The same transcripts show where the lead's own way of working cost
something. An honest audit reports these too, because they are the part
a strong collaborator can still improve.

- **Dictation run-ons at the highest-stakes moments.** The most
  important corrections were the least parseable turns: two paragraphs,
  no punctuation, "Does that make sense?" twice. They worked because of
  the read-back, which was needed *because* of the phrasing.
- **The audience arrives late.** "The team" was named in turn one; "for
  a non-technical reader" arrived two published versions later.
- **Corrections that lived in the lead's head.** Push rights, the
  production domain, and the PR preference each cost a round-trip before
  they were written down, and one of them never was.
- **Skepticism applied by spot, not by rule.** The "900 reviews" number
  was challenged; the DOM-node count, payload sizes, and contrast ratio
  in the same report were not. Spot-checks depend on the human noticing.
  A standing rule ("every number in a report cites its source") does
  not.
- **The handoff was declared ready unread.** The plan's eleven-slice
  shape, which the lead would not have accepted, left his hands
  without him reading it as the engineer would. The handback rule
  stayed in chat. Corrected on the first day of driving, three days
  late. Principle 3 applies to the handover artifact most of all.
- **The prior was wrong, and the evidence was allowed to say so.** The
  takeover opened with "they overengineered and lollygagged". The review
  found the pace fast against the plan's own sizing and located the
  real problems elsewhere: direction, proportion, and the shape of the
  plan that had been handed over. The lead let that verdict stand in
  writing. That is the move; the prior itself is the counterweight.

---

## The one-paragraph version

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

---

## The sixteen audit questions

The operative lines, collected for the audit path. The reasoning and
the examples are above.

1. **Open with the outcome, the why, and the future it must serve.** Did the first substantive turn state the outcome and the reason, and name any future the work has to serve? Or did it start with a task?
2. **State the operating constraints once, then write them into the repo.** Were constraints stated with reasons, and did they land in a committed file or a CLAUDE.md, or did the same correction recur?
3. **Name the reader and the bar.** Was the audience of each deliverable named before it was built? Was the bar stated as something an outsider could check?
4. **Carry only behaviour, look, and data from a legacy; re-derive the rest.** When a legacy or a prior project was in play, did the session distinguish "what to match" from "how it was built"? Did any legacy pattern leak into the new stack unchallenged?
5. **Trust no source by default, the agent included.** Did the human challenge at least one recommendation, estimate, or fact? Did they accept good answers quickly, or re-litigate?
6. **Ask for provenance before you accept a requirement.** When a requirement, number, or pattern appeared, did the human ask where it came from or whether it was real? Or did plausible things pass?
7. **Reopen tools and methods from first principles, mid-flow.** Did the human ever question a method or tool while it was working, or only when it failed?
8. **Decide fast, with the reason, and track what you are not solving.** Were small decisions made in one turn with a reason? Did deferred items get tracked somewhere durable, or just dropped?
9. **Product over prose; verify against the real thing.** What proportion of the session's output was product versus description of product? Was the verification gate "the flow runs against the real stack" or "the log says it passed"?
10. **Strip the ceremony the agent adds defensively.** Did the agent add process the human then removed? Did the removal get written down, or will it recur?
11. **Plan for the scaffolding to leave.** Was anything temporary created? Does it have a recorded removal condition?
12. **Long leash, periodic pull, and delegation enforced.** How many human turns were check-ins on progress versus decisions? Did the human confirm that the software runs, or let the gate do it?
13. **Separate alignment from action when the miss is big.** After a large correction, was alignment confirmed before rework started? Or did the second attempt also miss?
14. **Be the fast oracle and the hands for what only you can do.** When the agent was blocked on something only the human could do, how fast was the unblock, and how precise was the report back?
15. **Fix the system, not the instance.** Did any correction in the session become a durable instruction (CLAUDE.md, a memory, a doc)? Or does it live only in the transcript?
16. **Communicate outward from the work, in the right register.** Were outward messages produced per audience, and were claims calibrated? Did the human edit for the reader or just forward?
