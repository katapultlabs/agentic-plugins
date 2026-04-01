# PRD Template

Copy this file as `docs/prds/PRD-NNN-short-name.md` when creating a
new product requirement document.

---

```markdown
# PRD: [Feature Name]

**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved | Implemented
**Linear Project:** [Link to Linear project or epic]

## Problem Statement

[What problem are we solving? Who has this problem? Why does it matter
now? Keep this to 2-3 sentences.]

## Goals

- [What does success look like?]
- [What metric moves if we nail this?]

## Non-Goals

- [What are we explicitly NOT doing?]
- [What's out of scope for this iteration?]

These non-goals are important for agents too — they prevent scope creep
when an agent is implementing this feature.

## Proposed Solution

[How will we solve the problem? Include enough detail that an engineer
or agent could begin implementation. Reference any relevant ADRs or
RFCs for architectural decisions.]

## Success Criteria

These double as acceptance criteria for agent-driven implementation:

- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
- [ ] [Testable criterion 3]

## Dependencies

- [What needs to exist before this can be built?]
- [Other teams, services, or decisions this depends on]

## Open Questions

- [Anything unresolved that could affect implementation]
```
