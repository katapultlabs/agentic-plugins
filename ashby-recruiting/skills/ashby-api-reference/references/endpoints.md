# Ashby API Endpoint Details

Complete reference for all Ashby API endpoints used by this plugin.

## Base URL

`https://api.ashbyhq.com`

All endpoints use **POST** method with JSON body. Authentication is HTTP Basic Auth with API key as username, empty password.

Required headers:
```
Accept: application/json; version=1
Content-Type: application/json
```

---

## Candidate Endpoints

### candidate.list
List all candidates. Permission: `candidatesRead`.
```json
{"per_page": 100, "cursor": null}
```
Response fields: id, name, primaryEmailAddress (value, type, isPrimary), primaryPhoneNumber, createdAt, updatedAt, fileHandles, socialLinks, tags, allApplicationIds, location, linkedInUrl, githubUrl, websiteUrl.

### candidate.search
Search by name and/or email. Permission: `candidatesRead`. Max 100 results.
```json
{"name": "Jane", "email": "jane@example.com"}
```
When multiple params provided, they are combined with AND. Use this for targeted lookups, not bulk enumeration.

### candidate.info
Get details for a single candidate. Permission: `candidatesRead`.
```json
{"candidateId": "uuid"}
```
Returns full profile including all applications, tags, custom fields.

### candidate.listNotes
List notes on a candidate. Permission: `candidatesRead`.
```json
{"candidateId": "uuid"}
```

### candidate.createNote (WRITE — future use)
```json
{"candidateId": "uuid", "note": "text", "sendNotifications": false}
```

### candidate.addTag (WRITE — future use)
```json
{"candidateId": "uuid", "tagId": "uuid"}
```

---

## Job Endpoints

### job.list
List all jobs. Permission: `jobsRead`. Include `status` to filter.
```json
{"status": "Open"}
```
Status values: Open, Closed, Draft, Archived. Draft requires explicit inclusion.

Response fields: id, title, status, departmentId, locationId, employmentType, compensationTierSummary, openings, hiringTeam, customFields, createdAt, updatedAt, closedAt.

### job.search
Search jobs by keyword. Permission: `jobsRead`.
```json
{"term": "senior engineer"}
```

### job.info
Get details for a single job. Permission: `jobsRead`.
```json
{"jobId": "uuid"}
```
Returns full job details including compensation, openings with locations, hiring team, interview plan reference, custom fields.

---

## Application Endpoints

### application.list
List all applications. Permission: `candidatesRead`.
```json
{"per_page": 100, "cursor": null}
```
Response fields: id, status, createdAt, updatedAt, candidate (name, id), currentInterviewStage (id, title, type), job (id, title), source, archiveReason, hiringTeam, customFields.

Status values: Active, Hired, Archived.

### application.info
Get details for a single application. Permission: `candidatesRead`.
```json
{"applicationId": "uuid"}
```

### application.listHistory
Get the full history of stage transitions for an application. Critical for calculating time-in-stage.
```json
{"applicationId": "uuid"}
```

### application.changeStage (WRITE — future use)
```json
{"applicationId": "uuid", "interviewStageId": "uuid"}
```

### application.changeSource (WRITE — future use)
```json
{"applicationId": "uuid", "sourceId": "uuid"}
```

---

## Interview Endpoints

### interviewSchedule.list
List all scheduled interviews. Permission: `interviewsRead`.
```json
{"per_page": 100, "cursor": null}
```

### interviewStage.list
List all interview stages (pipeline stages). No parameters needed.
Returns: id, title, type, orderInInterviewPlan, interviewPlanId.

### interviewPlan.list
List all interview plans (pipeline templates).
Returns: id, title, stages.

### interviewEvent.list
List interview events (actual interviews that happened).
Returns: id, interviewScheduleId, startTime, endTime, interviewers.

### interviewerPool.list
List interviewer pools with member counts.
Returns: id, title, users, interviewStageId.

---

## Offer Endpoints

### offer.list
List all offers with their latest version. Permission: `offersRead`.
```json
{"per_page": 100, "cursor": null}
```
Response fields: id, applicationId, status, version, createdAt, decidedAt, compensation, startDate.

### offer.info
Get details for a specific offer.
```json
{"offerId": "uuid"}
```

---

## Organizational Endpoints

### department.list
List all departments. Returns: id, name, parentId, isArchived.

### location.list
List all locations. Returns: id, name, isRemote, address, isArchived.

### source.list
List all candidate sources. Returns: id, title, type (applied, sourced, referral, agency, etc.).

### user.list
List all Ashby users (team members). Returns: id, name, email, role.

### customField.list
List all custom fields. Returns: id, title, fieldType, objectType, selectableValues.

---

## Report Endpoints

### report.list
List available report definitions. Returns: id, title, type.

### report.run (synchronous)
Run a report and get results immediately. May timeout for large reports.
```json
{"reportId": "uuid", "filters": {}}
```

### report.start (asynchronous)
Start a report job. Returns a jobId to poll.
```json
{"reportId": "uuid", "filters": {}}
```

### report.result
Get results of an async report.
```json
{"reportJobId": "uuid"}
```

---

## Webhook Endpoints (for future event-driven use)

### webhook.create
```json
{"webhookUrl": "https://...", "secretToken": "...", "webhookType": "candidate.hired"}
```

Available webhook types: candidate.created, candidate.stageChanged, candidate.hired, application.created, offer.created, offer.accepted, offer.rejected, job.created, job.closed.
