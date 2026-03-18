---
name: ashby-api-reference
description: >
  This skill should be used when the user asks to "query Ashby", "pull data from Ashby",
  "call the Ashby API", "search candidates in Ashby", "get jobs from Ashby",
  "check applications", "get interview data", "pull offers", or any request
  that requires interacting with the Ashby ATS API. Also triggers when discussing
  Ashby API endpoints, authentication, pagination, or data schemas.
version: 0.1.0
---

# Ashby API Reference

Use this skill to make API calls to Ashby's ATS platform. All calls go through the helper script at `${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh`.

## Authentication

Ashby uses HTTP Basic Auth. The API key is the username; password is blank.

The script reads the API key from `$ASHBY_API_KEY` env var or `~/.ashby_api_key` config file.

**First-time setup — persist the key across shell calls:**

```bash
echo 'your-api-key-here' > ~/.ashby_api_key && chmod 600 ~/.ashby_api_key
```

This is the recommended approach in Cowork mode because each Bash tool call runs in a fresh shell — environment variables set via `export` do not persist between calls. The config file does.

**To get an API key:**
1. Log into Ashby as an Admin
2. Navigate to **Admin → Developer → API Keys** (https://app.ashbyhq.com/admin/api/keys)
3. Click **Create API Key**
4. Name it descriptively (e.g., "Claude Cowork Plugin")
5. Grant read permissions: `candidatesRead`, `jobsRead`, `offersRead`, `interviewsRead`
6. Copy the key and save it: `echo 'the-key' > ~/.ashby_api_key && chmod 600 ~/.ashby_api_key`

## Making API Calls

All Ashby API endpoints use POST. Call them via:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh <endpoint> '<json-body>'
```

Examples:
```bash
# List all open jobs
bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh job.list '{}'

# Search for a candidate by name
bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh candidate.search '{"name": "Jane Smith"}'

# Get details on a specific job
bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh job.info '{"jobId": "uuid-here"}'

# List all applications
bash ${CLAUDE_PLUGIN_ROOT}/scripts/ashby-api.sh application.list '{}'
```

## Pagination

Most list endpoints support cursor-based pagination. The response includes a `nextCursor` field. Pass it back to get the next page:

```json
{"cursor": "value-from-nextCursor", "per_page": 100}
```

Continue paginating until `nextCursor` is null or `moreDataAvailable` is false.

## Core Endpoint Reference

For detailed endpoint schemas, field definitions, and filter options, read `references/endpoints.md`.

### Quick Reference Table

| Goal | Endpoint | Key Parameters |
|------|----------|---------------|
| List all candidates | `candidate.list` | cursor, per_page |
| Search candidates by name/email | `candidate.search` | name, email |
| Get candidate details | `candidate.info` | candidateId |
| List candidate notes | `candidate.listNotes` | candidateId |
| List all jobs | `job.list` | status (Open, Closed, Draft, Archived) |
| Search jobs | `job.search` | term |
| Get job details | `job.info` | jobId |
| List all applications | `application.list` | cursor, per_page |
| Get application details | `application.info` | applicationId |
| List application history | `application.listHistory` | applicationId |
| List interviews | `interviewSchedule.list` | cursor, per_page |
| List interview stages | `interviewStage.list` | — |
| List interview plans | `interviewPlan.list` | — |
| List offers | `offer.list` | cursor, per_page |
| Get offer details | `offer.info` | offerId |
| List departments | `department.list` | — |
| List locations | `location.list` | — |
| List sources | `source.list` | — |
| List users | `user.list` | — |

## Response Handling

All responses follow this structure:
```json
{
  "success": true,
  "results": [ ... ],
  "moreDataAvailable": true,
  "nextCursor": "cursor-value"
}
```

On error:
```json
{
  "success": false,
  "errors": [{"message": "description"}]
}
```

Always check `success` before processing results. If `success` is false, report the error message to the user.

## Data Processing Guidelines

- When the user asks a broad question, break it into multiple API calls. For example, "How is our pipeline?" requires pulling jobs, applications, and interview stages.
- Always paginate through all results when doing aggregate analysis. Don't stop at the first page.
- Use `jq` for JSON processing in bash when parsing large responses.
- For time-based analysis, filter results by `createdAt` or `updatedAt` fields in post-processing.
- Present data in tables or summaries rather than dumping raw JSON to the user.
