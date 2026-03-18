---
description: Show recruiting pipeline and funnel metrics
allowed-tools: Bash, Read, Grep
argument-hint: [job-title-or-"all"]
---

Generate a recruiting pipeline report from Ashby data.

If `$ARGUMENTS` is provided, search for that specific job. Otherwise, report on all open jobs.

Steps:
1. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/ashby-api-reference/SKILL.md` for API patterns
2. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/recruiting-analytics/SKILL.md` for analysis playbooks
3. Fetch jobs: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh job.list '{"status": "Open"}'`
4. If a specific job was requested, filter to that job. Otherwise, analyze top 10 by activity.
5. Fetch all applications: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh application.list '{}'` — paginate through all results
6. Fetch interview stages: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh interviewStage.list '{}'`
7. For each job, group applications by current interview stage
8. Calculate conversion rates between stages
9. Present a funnel table per job showing: Stage | Count | Conversion % | Avg Days in Stage
10. Highlight bottlenecks (conversion < 20% or avg days > 14)
11. End with a summary: total open roles, total active candidates, any positions needing attention

Use `jq` for JSON processing. Present results in clean markdown tables.
