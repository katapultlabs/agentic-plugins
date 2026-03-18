---
description: View interview schedules and interviewer analytics
allowed-tools: Bash, Read, Grep
argument-hint: [interviewer-name, "schedule", or "load"]
---

Analyze interview data from Ashby — schedules, interviewer load, and interview pipeline.

Steps:
1. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/ashby-api-reference/SKILL.md` for API patterns
2. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/recruiting-analytics/SKILL.md` for interviewer load benchmarks
3. Determine what the user wants from `$ARGUMENTS`:
   - "schedule" or "upcoming" → show upcoming interview schedules
   - "load" or "balance" → analyze interviewer workload distribution
   - A person's name → show that person's interview activity
   - No argument → show overall interview summary
4. Fetch data:
   - Interview schedules: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh interviewSchedule.list '{}'`
   - Interview events: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh interviewEvent.list '{}'`
   - Interviewer pools: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh interviewerPool.list '{}'`
   - Users: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh user.list '{}'` (for name mapping)
5. For schedule view: upcoming interviews sorted by date with candidate, job, interviewers
6. For load analysis:
   - Group interviews by interviewer over the last 30 days
   - Calculate interviews/week per person
   - Flag overloaded (>6/week) and underutilized (<1/week) interviewers
   - Present as a ranked table
7. For individual view: that person's interview history, upcoming schedule, and load metrics

Present results in clean markdown tables with actionable insights.
