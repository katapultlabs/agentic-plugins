# An annotated session

The human's turns from the session in which the lead reviewed a
handed-over build, took it back, and shipped it to staging. Client and
people names are removed; the words are otherwise verbatim. The lead dictates
nearly everything, so read the run-ons and the odd homophone as
speech, not as writing. Each turn carries the move it makes (numbers refer to
`principles.md`). Task notifications, pasted command output, and the
agent's replies are omitted; where a reply matters, it is summarised in
brackets.

Read it for the rhythm: how little the lead types, how much of it is
direction and decision, and where the leash goes slack and tightens.

---

**Day one, evening. Design.**

> Alright, my friend, super fun project, we just signed the partnership
> so that we can help [the client] build their digital products ... the
> first thing that we're going to want to do is reimagine the
> architecture and we've already thought that we wanted to migrate the
> front end to Next.js and put it on Vercel, and then I think we want to
> migrate away from Python ... but here's the fun thing, eventually we're
> also thinking about mobile apps where we want to also share profiles
> and other information, auth and everything else, so it makes sense to
> also think about an API from the get go ... let's start this by
> creating our usual docs folder ... perhaps we can start with an RFC
> for everything that I just mentioned ... Does that make sense? Let me
> know if you have any questions.

*Move 1.* Outcome, decided constraints, the future the design must
serve, the first artifact, and an invitation to question. No how.

> A couple other guidances for this is that the repository should be
> fully self contained, and we should document anything important for
> future collaboration inside of the committed repository and not just
> in the local memory ... for now keep it simple with worktrees and
> branches but committing to main and moving fast and not
> overcomplicating things with too much CI or process until we have to
> ... however here we will likely want to have a staging environment
> because we already have production users.

*Move 2.* Constraints with reasons. This becomes a committed
ways-of-working document within the hour.

> Awesome! Let's commit what we have so far.

*Commit early.* Twenty minutes in.

> I'm wondering if we should consider using Supabase as well on the
> back end like we did on [a prior project] ... However, this smells
> like it's going to scale pretty quickly, so we want to consider
> whether we want to do Supabase or something that we can scale to
> Amazon once Railway becomes too small for us, or rather cost
> prohibitive.

*Move 5.* Brings a prior and his own doubt about it in the same
breath. The agent argues against; he accepts.

> But isn't Better Auth a closed source solution that locks us to that
> vendor?

*Move 5.* Challenges the recommendation with a concrete concern.
[Answer: MIT licensed, recently acquired, licence unchanged.]

> Ok, awesome. That's great news RE: the acquisition and the license.

> Like it.

*Move 5, the other half.* Two words. Decided.

> One of the things that we're already doing on the current platform is
> using the authentication solution from Cloudflare, which we should
> consider keeping for now unless we have a very good reason to change.

> Okay, that's really interesting, but I like what you're saying, maybe
> just keep Cloudflare Access for now just so that we can make the
> migration with one less piece, and then have a future plan to migrate
> to a better authentication that enables more complex onboarding flows
> as well as mobile apps.

*Move 8.* Prefers the smaller migration step, states the reason ("one
less piece"), and names the future trigger. (Later, the inventory shows
Cloudflare Access was never actually used; the decision is reversed on
evidence without ceremony.)

> One thing that we should also drive for as soon as possible is to
> have a fully self contained local environment that's very performant,
> so we can do the majority of the work locally without requiring
> upstream environments unless it's absolutely necessary. For example, I
> have OrbStack already installed.

*Move 2.* Another constraint with a reason and a concrete tool.

> We now have access to [the client's] GitHub, so let's use that to push
> our repo. We'll figure out the other questions when we review the
> legacy repo.

*Move 8.* Defers the open questions to the moment the evidence exists.

> What do you think is the best way to do a deep dive on the
> architecture and the technology and the code base and then come up
> with a thorough plan for how we move everything from that original
> architecture into the architecture we're proposing here, or is there a
> better way that you think we should consider doing that? Basically, we
> want to have a deep plan of how we want to do that and then commit to
> getting as much done as possible in one fell swoop. ... Ok, that work
> is done and on main locally in the v1 repo. Please get to it!

*Move 1 again, plus the ask for options.* "Or is there a better way"
invites the agent to propose the method. "One fell swoop" is the shape
of the plan he wants. Then: go.

> Good. Those are interesting findings, but know that the person that
> was leading the engineering is a designer by trade, so we also need to
> take that with a grain of salt and not take those things that they're
> using the right conventions as gospel. We have to take everything with
> a grain of salt and think for ourselves what is worth keeping.

*Move 5.* Calibrates a source.

> Again, and hopefully to stop beating a dead horse, part of this
> refactor is having a really good starting point with an impeccable
> architecture for us to start building a wonderful set of products for
> the organization.

*Move 3.* The bar, restated. He knows he is repeating it; he repeats it
anyway.

> And also something we should add to the plan is that we should test
> both environments locally by spinning up the environments so we can do
> as much testing one to one locally of everything before we escalate
> to an upstream environment. Also the work that you and I are doing
> here with this plan is something that we're going to hand over to
> someone else on our team.

*Move 3 and 9.* The reader of the plan, and the verification method
(side by side, locally).

> I think it's fine that members have to sign in once more at cutover,
> that is to be expected, and I think it's a low cost, we just have to
> make sure that we tell the product owner, so that's going to be the
> decision. We should also track the fact that the light palette fails
> the contrast, which is fine. The Railway login, don't worry about it,
> the engineer that's going to own this going forward will help us with
> that. And then we're not going to parallelize this with me and a
> second engineer. We're gonna hand it off to them so that they can
> continue with the build, and then you and I will continue later on
> once they have something for us to review.

*Move 8.* Four dispositions in one turn.

> The team shape, I don't know why we need to document that. I want him
> to push as much as possible and just get back to me when there's a
> fully ready to test environment of the full refactor.

*Move 9.* Cuts documentation that does not pull its weight, and states
the handback in one line. (This line did not make it into the plan
itself. See `handover-case.md` for what that cost.)

> Also, to be clear, does our RFC still include any mention of Supabase?
> Because if so, we should completely just remove Supabase for now, or
> at least just mention that we considered it, but it doesn't make sense
> given what we want to do, and the reason we came up for that.

*Doc hygiene.* A rejected option either leaves the doc or is recorded
as considered, with the reason. Never left ambiguous.

---

**Day four, afternoon. The review and the takeover.**

> All right, someone on our team has started to do the migration and
> they've committed a bunch of changes, however I feel like they're
> going very slowly. Let's do an analysis of what they've done so far,
> how well it's been done and what's missing. My take is that they
> overengineered the build and we should have just cranked to build a
> local environment as soon as possible, and they lollygagged and
> didn't manage the process well. I would have expected this to happen
> yesterday and they've been at it for over forty eight hours.

*Hypothesis stated, analysis requested.* Note the prior is explicit,
which is what lets the review disagree with it cleanly. [Three review
agents run. Verdict: pace fast against the plan's sizing; the problems
are direction and proportion.]

> Yeah, that feels like a lot of inefficiency in how this has been
> handled so far.

> Yeah, normally what I would have said is hey, let's make a plan to
> build all of this and then I would have told you to screw the slices
> and that sequencing and just build all of this as sequentially as
> possible, as fast as possible, as efficiently as possible.

*Move 9.* The shape he wanted, said out loud after the fact.

> You and I would have done it in a couple hours, max.

> Again, you don't know how to estimate those things. You say hours,
> but you normally accomplish them in minutes.

*Move 5.* Calibrates the agent's estimate, using the agent's own track
record as the baseline.

> And I wouldn't migrate it line by line; only fully migrate and
> refactor the frontend to Next.js and shadcn (with Base UI) so it's
> exactly the same UX/UI as the current one, and the backend I would
> migrate the APIs, functionality, etc. Also, migrate/refactor the data
> model.

> Yeah, that's silly. The frontend should be a complete refactor into
> our stack vs. bringing over the old frontend architecture/tech/
> patterns.

*Move 4.* The directional correction. Two turns.

> Also, are the tests and logs and microdecisions not overkill? I'd say
> just build and later we will rescan the architecture and polish and
> make tests, etc.

> No need to get bogged down for now.

> Fuck it. Seriously. Build the whole thing as much as possible, then
> boot up both environments and peg them against each other to make sure
> we have parity. No need to unit test every micro decision.

*Move 9.* Proportion, escalating over three turns until it is
unambiguous. Note what is kept: parity against both running stacks.

> Great. And when we're ready, we can hook up to current prod to export
> current prod data and do the work with that.

*Move 8.* Names the next gate and its input.

> Remember the global delegation rules.

*Move 12.* One line restores fan-out to smaller models.

> perfect

> Great. Delegate all the findings regarding the legacy architecture
> like the one you mentioned to our documents so we can create a report
> later on the findings and improvements we made with the new
> architecture we're building.

*Move 16, prepared early.* Findings go to a durable place now so the
outward report can be written later without re-mining the transcript.

[Eight turns of the lead running the gated production database dump
himself: SSH key registration, a wrong flag, a host-key failure, the
dump. Each error fixed in the next turn. Move 14.]

> keep going, ping me when parity is done

*Move 12.* The leash goes slack.

> Wait - is Playwright the right tool to be using? We can rethink
> everything from first principles.

> Why not use Chrome?

> So, from first principles, how do we now confirm and find any UX/UI
> issues with this combo? Are we also doing a full responsive pass?

*Move 7.* Reopens the method while it is working, proposes an
alternative, widens to coverage.

> Cool. What did we do with the legacy admin from standard Django?

> That's fine. Ok. Give me a quick brief summary of everything we've
> done to share with [the engineer] and the team so they know and don't
> push further.

*Move 6, then 16.* Provenance question; then the outward message, with
its purpose stated ("so they don't push further").

> And is the admin also on shadcn/Base UI?

> What's the no-JS requirement? And where did it come from?

> That's a silly requirement all around in 2026, for both the app and
> the admin.

> That's why it's so important we refactor into the technologies we
> chose from first principles, only functionality, UX/UI, data, in
> order to have a wonderful foundation on top of which to continue
> building.

*Moves 6 and 4.* The provenance question finds a leaked legacy rule;
it is killed and the principle behind the kill is restated.

> Great. And I think that the admin should have the `npx shadcn@latest
> add sidebar-08` layout to start.

*A concrete starting point.* When he has a specific preference, he
names it specifically.

> How we looking? It's been a long time

*Move 12.* The pull. Four words after several hours.

---

**Day five, morning. Shipping and communicating.**

> Great work. Give me a concise executive summary to post to the team
> on this progress to add to the previous brief I sent to them.

> That's great work. Just to be clear, we don't want this to run nightly
> in CI forever because we're going to switch over hopefully sometime
> next week, so we should also plan for leaving the pass behind without
> carrying performance or process baggage. ... Please also confirm that
> we have updated all of our documents so that we're in the most
> effective and collaboratively convenient way for anyone to come into
> a cold start session within the repository.

*Moves 11 and 15.* Scaffolding gets a retirement plan; the repo gets a
cold-start check.

> Sorry - not just the addendum. The new draft message to share to the
> team I can share with them.

> Perfect. Also, give me an executive summary for our non-technical
> stakeholders (CEO, cofounders, etc).

*Move 16.* One message per audience.

> Good stuff. The only thing that raised the flag for me is that given
> that we're gonna go on Vercel and Next.js, they have historically some
> strangeness in the way that they work with Cloudflare to protect
> things, but I think it makes sense that we're protecting the API
> that's going to be on Railway, and that's a separate topic, right?
> Just for me to deeply understand what you're saying.

*Move 5.* Checks his own understanding against a known gotcha before
forwarding a claim to others.

> Also I would caution against saying an architecture that will work for
> the next couple of years, instead saying should.

*Move 16.* Calibrates the claim.

> Please make it markdown in /tmp so I can pbcopy it because the copy
> paste here is not perfect.

> Remind me. We chose Better Auth, right? And that sits on Vercel/
> Next.js? How does that work with the API auth?

*Move 5.* Asks the question he would be asked.

> Looks like the GitHub repo isn't connected to Vercel. Shouldn't we do
> that first?

> Can you hook it up yourself? Also, Vercel already shows [the stable
> URL] as the URL.

> I installed both GitHub apps, but also connected them to the
> repository, however I didn't do any other configuration ... assume
> that I only did the initial configuration to the right repository,
> but everything else is missing. Also, I added the apps to all
> repositories because the risk is small, so that we can use other
> repositories and projects in the future.

*Move 14.* Spots the missing step, delegates what can be delegated,
does the part only he can do, reports exactly what was and was not
done, and gives the reason for the scope he chose.

> Nicee.... however, why Resend vs. Cloudflare email?

> Again, your knowledge is stale :)

> What's the most effective and efficient directive for the global LLM
> directive on not trusting the training for when recommending versions
> or solutions? "When recommending solutions, versions, technologies,
> etc based on your training, always offer something along the lines of
> `this is based on my knowledge cutoff and we should validate with
> quick research`" But better :)

> I like that. What I want to prevent is unnecessary and expensive extra
> work; just the notification and suggestion.

> What's the most effective and token-efficient version of this?

> Yes, make it so.

*Move 15, in full.* A stale recommendation becomes a permanent global
directive in five turns, scoped down twice on the way.

> Thanks! OK. We're about to compact. Anything we should do in terms of
> documentation or else before that so a cold session can be as
> effective as us?

*Move 15.* Memory hygiene before the context is lost.

> I can't get past this: [screenshot]

> Still nothing. Test it yourself on Chrome using my email and let me
> know when I should check the email.

> Ok! I got the email, but it was already expired. Good stuff!

> Okay great, I was able to log in, but that email that I used was
> already working in the production environment, and when I
> successfully used the link on this one it asked me to create my new
> profile handle. Also something weird happened in that I used the same
> login link on the page where I was previously requesting it, and
> nothing happened. ... I was at the page, requested the link, went to
> my email, copied the link, went back to the browser, was on the same
> tab, and then I pasted the link in that same one, pressed Enter, and
> nothing happened, and then I opened a new tab, pasted the login link
> from the email, and then that one did log me in, but it took me to an
> account creation flow.

*Move 14.* A bug report precise enough to reproduce without a
follow-up.

> Alright, that's a little silly because we should make our current
> Vercel environment as prod-like as possible, so that everyone's
> testing against their expectations of how production is currently
> working.

*Move 2.* A new constraint (staging holds real data) with its reason
(the team tests against production expectations). Then he runs the
load himself.

> How we looking?

---

## What to notice

- Across three sittings, about seven active hours, and 146 turns, the
  lead typed about 4,500 words.
  Half the turns are "go", "perfect", "how we looking", or a command he
  ran himself. The direction lives in perhaps twenty turns.
- Every correction carries its reason. "That's silly" is always
  followed by why.
- The leash is long when the gate is clear ("ping me when parity is
  done") and short when the premise is in doubt (the review, the
  Playwright question).
- The moments that compounded (moves 2, 11, 15) are the ones where a
  correction left the chat and became a file.
- The costs are visible too: the plan declared ready for handoff
  without being read in its slice shape, the handback rule that stayed
  in chat instead of the plan, the audience named after the artifact,
  and the prior that the review had to overrule.
