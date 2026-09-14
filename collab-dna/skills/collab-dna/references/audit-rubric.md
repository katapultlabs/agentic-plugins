# Audit rubric

How to turn a session transcript into feedback the human can act on.
Read `principles.md` first; this file is only the procedure and the
report shape.

## What an audit is for

The human wants to get better at building with an agent. The audit's
job is to show them, from their own words, which moves they made, which
they missed, and what the missed ones cost. It is coaching, not
grading. A report that says "7/10" teaches nothing; a report that
quotes the turn where the audience should have been named, and shows
the two rebuilds that followed, teaches the move.

Three things make an audit useful and each is easy to skip:

1. **Quote the human.** Every finding cites the turn it comes from. If
   you cannot quote it, you have not found it.
2. **Name the cost.** "You did not name the reader" is an observation.
   "You did not name the reader until turn 9; turns 4 to 8 built a page
   for the wrong one" is a finding.
3. **Give the better move as words they could have typed.** Not
   "be clearer about scope" but the sentence that would have set it.

## Procedure

1. Get the transcript. For a past session, run
   `scripts/extract_session.py extract <target> --stats` (see the
   command in `commands/audit.md`). For the current conversation, you
   already have it; skip the script.
2. Read the human's turns in order. Ignore the assistant's turns except
   to see what each human turn caused. The assistant's behaviour is
   evidence about the human's inputs, not the subject.
3. Write the arc in one paragraph: what they wanted, how it went, where
   it turned.
4. Walk the sixteen moves in `principles.md`. For each, decide whether
   it was **present**, **partial**, **absent**, or **not applicable**
   (some sessions have no legacy, no outward message, no scaffolding).
   Mark a move present only with a quote. Absent needs the moment where
   it would have applied. A session with fewer than about five typed
   turns is **too short** to score most moves; use that word rather
   than n/a, which means the move had no occasion, and leave such
   sessions out of project-wide counts. When the session deliberately inverted a move
   (asked for a faithful copy, chose to add ceremony for a real reason,
   kept scaffolding on purpose), score it on whether the inversion was
   stated with its reason; a stated, reasoned inversion is present, an
   unstated one is partial, and say which in the evidence cell.
5. Pick the findings that cost the most: one to three. A single
   finding that matters beats three where the third is padding; say
   when there is only one. Cost is measured
   in wasted turns, rebuilt artifacts, wrong direction held for a long
   time, or corrections that will recur because they were not written
   down. Rank by that.
6. For each, write the better move as a sentence in the human's own
   voice, something they could paste into their next session.
7. Find the one thing that should become a standing instruction
   (CLAUDE.md, a memory, a doc). There is almost always one: a
   preference stated twice, a fact the agent had to ask for, a
   correction the agent could not have anticipated.
8. Report also what was strong. Not as a compliment sandwich; because a
   move done well is the reference for doing it again, and because the
   human needs to know which instincts to keep.

## The model lines

Both report shapes open with two model lines, and they are not
decoration. A session run on a small model produces more corrections,
more stops, and more ceremony than the same human would produce on a
large one, and an audit run on a small model misses moves. The reader
of a report, often not the person who ran it, has to be able to
discount both. The extract header names the model that answered every
assistant turn (subagents' models are not visible). Your own model id
is in your system prompt; state it, and if the model that ran the
session was smaller than the one auditing, say so in the arc.

## Signals in the stats block

`extract_session.py --stats` prints counts. They are not a score; they
are prompts for where to look.

- **`user_words` far above `assistant_words`**: the human is typing the
  work. (Both counts exclude injected content: slash-command
  expansions and skill bodies are listed in the extract but not
  counted.) Look for turns that describe *how* instead of *what*, and for
  task lists.
- **Many short turns in a row** ("ok", "yes", "do it"): usually healthy,
  the human approving and moving. Check that the approvals were of
  proposals, not of the agent asking permission for routine steps (move
  10).
- **`questions_asked_by_user` low over a long session**: the human may
  be accepting outputs unchallenged (moves 5, 6).
- **`subagent_notifications` zero on a large build** (the same count
  is the "Subagent notifications" column in a project index): no
  fan-out. Check
  whether the work had independent units that could have run in
  parallel.
- **`commands_run_by_user` zero when the agent reported being blocked**:
  the human may have waited instead of unblocking (move 14).
- **`compactions` more than one**: check whether anything was written
  down before each one (move 15).
- **`span_hours` long with few human turns**: good leash, if the gates
  were real. Check what the human asked at each return.
- **`span_hours` against `active_hours`**: span is calendar time from
  first record to last, and a session resumed over several days spans
  all of them, nights included; active is the sum of gaps under ten minutes between
  turns, which approximates the time the human and the agent were
  actually exchanging. People take breaks and leave agents running.
  Report work in active hours and say so; a report that calls a
  ninety-hour span "three days of work" is wrong in a way the reader
  will notice. Idle inside a span is a finding only when it was the
  agent waiting on the human (a stop, an approval), not when the human
  was elsewhere.
- **The `+Nm` gap on a human turn** is the time since their previous
  turn. Long gaps before a correction show how long a wrong direction
  was held; that is the cost figure for ranking findings.

## Report shape

Use this shape. Headings are fixed; keep each section short.

```
# Session audit: <session id or "this conversation">

<one-line facts: date, active hours (span in brackets), human turns,
what was built>
Session ran on: <model(s) from the extract header>. Audited with: <your
own model id, from your system prompt; "unknown" if you cannot tell>.

## The arc
<one paragraph>

## Moves
| # | Move | Result | Evidence |
| --- | --- | --- | --- |
| 1 | Outcome, why, horizon | present | "…" (turn 1) |
| … |
(one row per move; result is present / partial / absent / n/a;
evidence is a short quote and the turn number, or the moment it
would have applied)

## What cost the most
### 1. <finding as a claim>
What happened: <quote, turn numbers, the consequence in turns or rework>
The move: <the sentence they could have typed instead>
(a second and third finding only if each earns its place; say when
there is only one)

## What to keep doing
<two or three moves done well, each with its quote; these are the
reference for next time>

## Write this down
<the one instruction that should leave the transcript and go into
CLAUDE.md, a memory, or a doc, with the exact wording proposed>

## Next session
<three lines, imperative, specific to this human's pattern>
```

## Dictation

Many people dictate to the agent and only type when it is faster. Long
unpunctuated turns, homophone errors ("police" for "please"), a
message sent twice, and spoken tics are transcription artifacts, not
habits, and they are never a finding on their own. Read intent through
them. The finding, when there is one, is a high-stakes dictated turn
that was acted on without a read-back (move 13). Quote such turns as
they are, and say the error did not matter when it did not.

## Tone

Direct, specific, no hedging, no praise inflation. Quote the person
accurately, including dictation errors if the error mattered. Call the
strong moves strong and the missed ones missed. Do not soften a
finding because the session was successful overall; a successful
session with three avoidable rebuilds is the most instructive kind.

Do not moralise about the agent's behaviour. If the agent added
ceremony or guessed wrong, the finding is about what the human's
instructions made possible, and the fix is an instruction.

## When the transcript is the current conversation

Everything above applies, with one difference: you were the agent. Be
as honest about the turns where your own output pulled the human off
course as about the human's turns. The audit is still of the human's
moves, but the reader can see both sides, and a report that blames
only one is not credible.

## Auditing a whole project

One session shows moves; a project shows habits. The same correction
typed in three sessions is a standing instruction that was never
written. A move absent in every session is a blind spot, not a bad
day. A move present early and absent later is drift. None of that is
visible from inside one transcript, and it is the most useful thing an
audit can say.

Procedure:

1. Run `scripts/extract_session.py project` (see `commands/audit.md`).
   It writes one extract per session and an `index.md` with a
   per-session stats table. Read the index first.
2. Decide the working set. Up to about six sessions, read them all.
   Beyond that, or when the extracts are large, fan out: one subagent
   per session (or per group of small sessions), each producing the
   single-session report above, and synthesise from those reports.
   Give each subagent the two reference files and the report shape;
   ask it to return the moves table and the findings only. Do not try
   to hold twenty transcripts in one context.
3. Build the recurrence table: for each move, how many sessions
   present, partial, absent, n/a. Sort by absent count. Sessions
   marked too short are listed but not counted.
4. Find the repeated corrections. Read the human's turns for
   sentences that appear, in substance, more than once across
   sessions: "don't open a PR", "remember the delegation rules", "the
   audience is". Each one is a candidate standing instruction, and the
   count of repeats is its cost.
5. Look for trajectory: the first session against the last. What
   improved, what did not, what got worse as the work got bigger.
6. Rank findings by cost across the project, not within a session.
   A move missed once in a two-hour session ranks below a move missed
   in every session.

Report shape for a project:

```
# Project audit: <project name>

<one-line facts: sessions, date range, typed turns, typed words,
total active hours (total span in brackets)>
Sessions ran on: <models from the index>. Audited with: <your own
model id; "unknown" if you cannot tell>.

## What the sessions were
<one line per session: date, what it was for, how it went; from the
index and the arcs>

## Habits
| # | Move | Present | Partial | Absent | n/a | Note |
| --- | --- | ---: | ---: | ---: | ---: | --- |
(one row per move, counts across sessions, sorted by absent;
the note names the sessions or the pattern)

## Repeated corrections
<each correction the human typed in more than one session, quoted
once per session with the session id, and what it cost in total>

## Trajectory
<first session against last: what improved, what did not, what got
worse with scale>

## What cost the most
### 1. <finding as a claim, project-wide>
What happened: <sessions, quotes, the total cost>
The move: <the sentence, or the instruction to write>
(more only if each earns its place)

## What to keep doing
<the moves that were present in every session, with one quote each>

## Write this down
<the standing instructions, ranked by how many sessions they would
have saved a turn in, with proposed wording for each>

## Next session
<three lines>
```

The single-session rubric's rules still apply: quote or it did not
happen, coaching not grading, do not moralise about the agent, keep
private material out of the repo. In both report shapes, refer to
other people by role ("the engineer", "the product owner"), not by
name, even when the human named them; the extract redacts email
addresses and credentials but not names unless `--redact` was given.
