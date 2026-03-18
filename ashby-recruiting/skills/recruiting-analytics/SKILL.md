---
name: recruiting-analytics
description: >
  This skill should be used when the user asks "how is our pipeline",
  "how are we doing with hiring", "recruiting metrics", "time to fill",
  "conversion rates", "source effectiveness", "interviewer load",
  "offer acceptance rate", "hiring velocity", "pipeline health",
  "who do we have for this role", "find candidates for", "talent search",
  or any question about recruiting performance, candidate fit, or hiring insights.
version: 0.1.0
---

# Recruiting Analytics & Insights

Use this skill to interpret Ashby data and produce actionable recruiting insights. Combine this with the `ashby-api-reference` skill to fetch the raw data.

## Analysis Playbooks

### Pipeline Health Check

When the user asks "how is our pipeline" or "how are we doing with [position]":

1. Fetch the job(s) via `job.list` or `job.search`
2. Fetch all applications for those jobs via `application.list`
3. Fetch interview stages via `interviewStage.list`
4. Group applications by current stage
5. Calculate:
   - **Total candidates** per stage
   - **Conversion rate** between each stage (candidates who advanced / candidates who entered)
   - **Drop-off rate** at each stage (archived / entered)
   - **Average time in stage** using `application.listHistory`
6. Present as a funnel table with stage name, count, conversion %, and avg days

Flag any stage with conversion below 20% or avg time above 14 days as a bottleneck.

### Time-to-Fill Analysis

When the user asks about "time to fill" or "hiring speed":

1. Fetch closed/hired applications via `application.list` (filter status: Hired)
2. Calculate days between application `createdAt` and the hired date
3. Group by job title, department, or location as requested
4. Present: median, average, P75, P90 time-to-fill
5. Compare against benchmarks (see `references/benchmarks.md`)

### Source Effectiveness

When the user asks "where are our best candidates coming from":

1. Fetch all applications via `application.list`
2. Fetch sources via `source.list`
3. Group applications by source
4. For each source, calculate:
   - **Volume**: total applications
   - **Quality**: % that passed first screen
   - **Efficiency**: % that reached offer stage
   - **Hire rate**: % that were hired
5. Rank sources by hire rate, then by quality

### Candidate Search & Matching

When the user asks "who do we have for [role]" or "find candidates who fit [description]":

1. Parse the role requirements from the question
2. Search candidates via `candidate.search` (by name/keyword if specific)
3. For broader searches, pull `candidate.list` and filter by:
   - Tags
   - Previous application history (roles they applied to)
   - Location
   - Skills mentioned in notes
4. Cross-reference with `application.list` to check previous engagement
5. Present a shortlist with: name, current status, relevant experience indicators, last interaction date
6. Flag any candidates who were previously archived with a reason

### Interviewer Load Balancing

When the user asks about "interviewer workload" or "who is doing the most interviews":

1. Fetch interview events via `interviewEvent.list`
2. Group by interviewer
3. Calculate per interviewer:
   - Total interviews in the period
   - Interviews per week
   - Unique candidates interviewed
4. Identify overloaded interviewers (>6 interviews/week) and underutilized ones (<1/week)
5. Present as a ranked table

### Offer Metrics

When the user asks about "offer acceptance" or "offer metrics":

1. Fetch all offers via `offer.list`
2. Group by status (accepted, rejected, pending, expired)
3. Calculate:
   - **Acceptance rate**: accepted / (accepted + rejected)
   - **Time to decision**: days between offer created and decided
   - **Compensation trends**: if compensation data is available
4. Break down by department or role if requested

## Presentation Guidelines

- Always present metrics in clean tables
- Include the time period analyzed
- Compare against benchmarks when available (see `references/benchmarks.md`)
- Highlight anomalies and actionable insights
- Suggest next steps based on findings
- If data seems incomplete (e.g., very few results), mention it and suggest checking API permissions or date ranges

## Conversational Analysis

When the user asks an open-ended question like "how are we doing with hiring":

1. Start with a high-level summary: total open positions, active candidates, recent hires
2. Highlight any positions that need attention (long time open, low pipeline)
3. Note any positive trends (fast fills, strong sources)
4. Ask if they want to drill into any specific area

When the user asks about a specific position:

1. Fetch the job details
2. Show the current pipeline funnel for that job
3. List the candidates in each stage
4. Flag any stalled candidates (no stage change in >7 days)
5. Suggest actions if the pipeline is thin
