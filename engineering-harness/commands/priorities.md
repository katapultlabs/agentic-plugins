---
description: Show current sprint priorities from Linear
---

Query Linear for the current sprint's priorities. Follow this sequence:

1. Call the Linear MCP's list_cycles tool to find the active cycle
2. Call list_issues filtered to that cycle, sorted by priority (highest first)
3. Present the top 5 items in a clean table:

   | # | Priority | Status | Issue | Assignee |
   |---|----------|--------|-------|----------|

4. If any high-priority items are unassigned, flag them:
   "These high-priority items have no owner yet — want to pick one up?"

5. If the engineer says which issue to work on, transition to the
   /harness:start-task flow for that issue.

If there is no active cycle, say so and offer to show all open issues
sorted by priority instead.
