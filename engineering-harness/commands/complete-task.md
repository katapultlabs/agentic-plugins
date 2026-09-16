---
description: Complete a Linear issue — update status, post summary, link PR
argument-hint: [issue-id]
---

Wrap up work on a Linear issue. Follow this sequence:

1. Look up the issue using $ARGUMENTS. Read its agreed acceptance criteria
   and the team's review/merge requirements for completion.
2. Gather a summary of the work done:
   - What files were changed or created
   - What approach was taken
   - Results and evidence for each required acceptance check, including
     tests and any checks that failed, were skipped, or could not run
   - PR link if one was created

3. Check whether all acceptance criteria and completion requirements are
   met. An open PR or passing tests alone is not enough. If a required
   check failed or is unverified, or review/merge is still required, post
   the evidence and remaining blocker, leave the issue in an appropriate
   non-complete state, and stop. If the criteria are unclear, ask rather
   than inventing them. Use checks appropriate to the task; not every
   task needs browser testing or deployment.

4. Post a summary comment to the Linear issue using the Linear MCP's
   create_comment tool. The comment should include:
   - Brief description of what was done
   - List of key files changed
   - PR link (if applicable)
   - Acceptance results and supporting evidence
   - Any follow-up work identified

5. Move the issue status to "Done" (or the team's equivalent completion
   state) using the update tool. Read back the issue to confirm the change.

6. Check for follow-up work: if the implementation revealed new work
   that needs to be done, run the duplicate check (from
   /harness:check-duplicates) before creating any new issues. Link new
   issues back to the completed one.

7. Confirm: "Completed [ISSUE-ID]: [title]. Summary posted, status
   updated to Done. [N follow-up issues created / No follow-up needed.]"
