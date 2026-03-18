---
description: Search and analyze candidates in Ashby
allowed-tools: Bash, Read, Grep
argument-hint: [name, email, or role-description]
---

Search for candidates in Ashby and present their profiles and application history.

Steps:
1. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/ashby-api-reference/SKILL.md` for API patterns
2. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/recruiting-analytics/SKILL.md` for candidate matching guidance
3. Parse what the user is looking for from `$ARGUMENTS`:
   - If it looks like a name → use `candidate.search` with the name
   - If it looks like an email → use `candidate.search` with the email
   - If it describes a role/skillset → search jobs first to find relevant positions, then pull applications for those jobs to find matching candidates
4. For each candidate found:
   - Get full details via `candidate.info`
   - List their applications and current stages
   - Note tags, source, and last activity date
5. Present as a summary table: Name | Current Stage | Job | Source | Last Activity
6. For detailed view, show full profile including notes and application history
7. If searching broadly (role description), also check `candidate.list` with tag filtering

If no results found, suggest broadening the search or checking spelling.
