# Ashby Recruiting Plugin

A Claude Cowork plugin that connects to your Ashby ATS via API for recruiting analytics, candidate search, pipeline management, and hiring insights.

## Setup

### 1. Get Your Ashby API Key

1. Log into Ashby as an **Admin**
2. Go to **Admin → Developer → API Keys** at [app.ashbyhq.com/admin/api/keys](https://app.ashbyhq.com/admin/api/keys)
3. Click **Create API Key**
4. Name it: `Claude Cowork Plugin`
5. Grant these read permissions:
   - `candidatesRead` — access candidate profiles and applications
   - `jobsRead` — access job listings and details
   - `offersRead` — access offer data
   - `interviewsRead` — access interview schedules and events
6. Copy the generated key

### 2. Save Your API Key

Save the key to a config file so it persists across all shell calls in Cowork mode:

```bash
echo 'your-api-key-here' > ~/.ashby_api_key && chmod 600 ~/.ashby_api_key
```

The script checks this file automatically. Alternatively, you can set the `ASHBY_API_KEY` environment variable, but note that in Cowork mode each Bash call runs in a fresh shell so `export` won't persist between calls.

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/ashby-pipeline` | Pipeline funnel and conversion metrics | `/ashby-pipeline Senior Engineer` |
| `/ashby-candidates` | Search and analyze candidates | `/ashby-candidates Jane Smith` |
| `/ashby-jobs` | List and analyze open positions | `/ashby-jobs all` |
| `/ashby-interviews` | Interview schedules and load analysis | `/ashby-interviews load` |
| `/ashby-offers` | Offer metrics and pending offers | `/ashby-offers metrics` |

## Skills

The plugin includes two skills that activate automatically in conversation:

- **ashby-api-reference** — Ashby API endpoint knowledge, authentication patterns, and data schemas. Triggers when you ask to query or pull data from Ashby.
- **recruiting-analytics** — Recruiting metrics interpretation, benchmarks, and analysis playbooks. Triggers when you ask about pipeline health, hiring velocity, source effectiveness, or candidate fit.

## What You Can Do

### Reports & Analytics
- "How is our pipeline looking?"
- "What's our time-to-fill for engineering roles?"
- "Which sources are producing the best candidates?"
- "Show me interviewer workload distribution"
- "What's our offer acceptance rate this quarter?"

### Candidate Intelligence
- "Who do we have in the database that could fit a senior React role?"
- "Search for candidates named Maria Garcia"
- "Show me all candidates currently in final round"

### Position Management
- "List all open positions with their pipeline counts"
- "How long has the Product Manager role been open?"
- "Which positions need more candidates?"

## Architecture

This plugin uses direct Ashby API calls via a bash helper script — no MCP server required. The API uses HTTP Basic Auth with your API key as the username.

All endpoints are POST-based (Ashby uses RPC-style API) and return JSON responses with cursor-based pagination.

## Future Enhancements (v0.2.0)

Write operations are designed into the API reference but not yet exposed via commands:
- Add notes to candidates
- Tag candidates for projects
- Move candidates between pipeline stages
- Create new job postings
