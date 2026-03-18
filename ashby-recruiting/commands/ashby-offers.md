---
description: View and analyze offers and acceptance metrics
allowed-tools: Bash, Read, Grep
argument-hint: ["metrics", "pending", or candidate-name]
---

Analyze offer data from Ashby — pending offers, acceptance rates, and compensation trends.

Steps:
1. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/ashby-api-reference/SKILL.md` for API patterns
2. Read the skill at `${CLAUDE_PLUGIN_ROOT}/skills/recruiting-analytics/SKILL.md` for offer benchmarks
3. Determine focus from `$ARGUMENTS`:
   - "metrics" or "rates" → overall offer acceptance analysis
   - "pending" → list all pending/outstanding offers
   - A candidate name → search for that candidate's offer status
   - No argument → show summary with pending offers and recent metrics
4. Fetch offers: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh offer.list '{}'` — paginate through all
5. For metrics view:
   - Group offers by status (accepted, rejected, pending, expired)
   - Calculate acceptance rate, avg time to decision, offers per hire
   - Break down by department/role if data allows
   - Compare against benchmarks from references
6. For pending view:
   - Filter to active/pending offers
   - Show candidate name, role, days since offer sent
   - Flag any offer pending > 7 days
7. For candidate-specific view:
   - Search candidate, find their application, show offer details and status

Present results in clean markdown tables with recommendations.
