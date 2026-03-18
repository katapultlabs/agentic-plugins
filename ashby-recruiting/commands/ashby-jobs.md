---
description: List and analyze open jobs and positions
allowed-tools: Bash, Read, Grep
argument-hint: ["all" or job-title-keyword]
---

List and analyze jobs/positions in Ashby.

Steps:
1. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/ashby-api-reference/SKILL.md` for API patterns
2. If `$ARGUMENTS` is a keyword, search: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh job.search '{"term": "$ARGUMENTS"}'`
3. Otherwise, list all open jobs: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh job.list '{"status": "Open"}'`
4. For each job, fetch application count from `application.list` and group by status
5. Fetch department and location info for context
6. Present a summary table: Job Title | Department | Location | Status | Active Candidates | Days Open
7. Sort by most candidates first, or by days open if the user is looking for stale positions
8. Highlight any job open > 60 days with < 5 active candidates as needing attention
9. If the user asks about a specific job, drill into that job's full details including:
   - Compensation info
   - Hiring team
   - Pipeline breakdown by stage
   - Recent candidate activity

Use `jq` for JSON processing. Present results in clean markdown tables.
