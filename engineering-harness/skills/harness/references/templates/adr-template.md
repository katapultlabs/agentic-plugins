# ADR Template

Copy this file as `docs/adrs/ADR-NNN-short-name.md` when recording an
architecture decision. Number sequentially. Once an ADR is Accepted,
it should not be modified — supersede it with a new ADR instead.

An ADR is evidence, not a commitment. It earns deference only as long
as its premises hold, so write the premises down: a future session
(human or agent) reopens the decision when one of them fails or when
reversal has become cheap, and otherwise leaves it alone. When a
decision is revisited, write the superseding ADR and mark this one
`Superseded by`; never build a workaround next to a record that still
says Accepted.

---

```markdown
# ADR-NNN: [Decision Title]

**Date:** [YYYY-MM-DD]
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNN
**Supersedes:** [ADR-NNN, or "none"]
**Reversibility:** Two-way door | One-way door
[One-way: data models, public contracts, migrations, anything costly to
undo. One-way doors keep the old caution when someone proposes reopening.]
**Deciders:** [Names of humans and/or agents involved]

## Context

[What is the situation that requires a decision? What forces are at
play — technical constraints, business requirements, team capabilities,
timeline pressure? Be specific enough that someone reading this in
six months (human or agent) understands why this decision was needed.]

## Decision

[What did we decide to do? State the decision clearly and concisely.
"We will use X for Y because Z."]

## Premises

[The facts this decision rests on, one per line, each checkable later:
"traffic is under 50 rps", "the team has no mobile client", "library X
does not support Y". If a premise stops being true, the decision is
open again. A decision with no stated premises cannot be reopened on
evidence, only on opinion.]

## Alternatives Considered

### [Alternative 1]
- Pros: [...]
- Cons: [...]
- Why rejected: [...]

### [Alternative 2]
- Pros: [...]
- Cons: [...]
- Why rejected: [...]

## Consequences

### Positive
- [What becomes easier or better as a result of this decision?]

### Negative
- [What becomes harder? What tradeoffs are we accepting?]

### Risks
- [What could go wrong?]

## Reopen When

- [The concrete trigger: a premise above fails, or reversal becomes
  cheap (the migration is scripted, the contract has no consumers yet).
  Absent a trigger, the burden is on whoever wants the change.]

## References

- [Links to relevant PRDs, RFCs, external docs, or Linear issues]
```
