---
description: Search Linear for duplicate issues before creating a new one
argument-hint: [description of the issue you want to create]
---

Before creating a new Linear issue, check whether it already exists.

1. Take the description provided in $ARGUMENTS
2. Extract 3-5 key terms from the description
3. Search Linear using list_issues with those terms as keyword filters
4. Review the results:

   **If likely duplicates are found** (similar title or overlapping intent):
   - Show each potential match with its ID, title, status, and assignee
   - Ask: "One of these might already cover what you need. Want to comment
     on an existing issue instead of creating a new one?"

   **If no matches found:**
   - Report "No duplicates found" and offer to create the issue now
   - If creating, ask for title, priority, and assignee (or suggest defaults)

5. If creating a new issue, always apply the team's default labels and
   link it to the current project/cycle if one is active.

The goal is to prevent issue sprawl. In a team where both humans and
agents file work, duplicates accumulate fast if nobody checks first.
