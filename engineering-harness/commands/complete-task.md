---
description: Complete a Linear issue — update status, post summary, link PR
argument-hint: [issue-id]
---

Wrap up work on a Linear issue. Follow this sequence:

1. Look up the issue using $ARGUMENTS
2. Gather a summary of the work done:
   - What files were changed or created
   - What approach was taken
   - Whether tests pass
   - PR link if one was created

3. Post a summary comment to the Linear issue using the Linear MCP's
   create_comment tool. The comment should include:
   - Brief description of what was done
   - List of key files changed
   - PR link (if applicable)
   - Any follow-up work identified

4. Move the issue status to "Done" (or the team's equivalent completion
   state) using the update tool

5. Check for follow-up work: if the implementation revealed new work
   that needs to be done, run the duplicate check (from
   /harness:check-duplicates) before creating any new issues. Link new
   issues back to the completed one.

6. Confirm: "Completed [ISSUE-ID]: [title]. Summary posted, status
   updated to Done. [N follow-up issues created / No follow-up needed.]"
