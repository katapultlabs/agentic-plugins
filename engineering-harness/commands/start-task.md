---
description: Pick up a Linear issue and start working on it
argument-hint: [issue-id or issue identifier]
---

Start working on a Linear issue. Follow this sequence:

1. Look up the issue using $ARGUMENTS (accept Linear issue ID like
   "ENG-123" or a search term)
2. Display the issue details: title, description, acceptance criteria,
   priority, and any linked issues or PRDs
3. Move the issue status to "In Progress" using the Linear MCP's
   update tool
4. Confirm the status change to the engineer

5. Load context: if the issue description references any files, PRDs,
   ADRs, or docs in the repo, read them so you have full context before
   starting work.

6. Summarize: "I've picked up [ISSUE-ID]: [title]. It's now In Progress.
   Here's what I understand needs to happen: [brief summary]. Ready to
   start?"

If the issue is already "In Progress" and assigned to someone else,
warn the engineer: "This issue is already being worked on by [assignee].
Want to proceed anyway, or pick a different one?"
