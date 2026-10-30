---
name: contracts
description: "Katapult's contract process. Use before any work on a client or partner agreement: drafting, reviewing, redlining, comparing against a template, sending for review, or signing an MSA, SOW, DPA, NDA, referral or recruiting agreement. Triggers: 'contract', 'MSA', 'SOW', 'DPA', 'NDA', 'redline', 'agreement', 'review the draft', 'send for signature'."
---

# Katapult contracts

The process lives in one shared Google Doc, not in this skill. This skill only tells you where it is.

**Source of truth:** "How we draft, send and sign contracts", Google Doc ID `1b2FMsqQjw6BhLnwLUzbwveNAKmECFpqum8AJgKSdojQ`
(https://docs.google.com/document/d/1b2FMsqQjw6BhLnwLUzbwveNAKmECFpqum8AJgKSdojQ/edit), in the shared drive under Shared Resources & Knowledge Base / Contracts. Owner: Sara Calle.

## Steps

1. Before any contract work, read the doc with the Google Drive connector (`read_file_content`, `includeComments: true`). Read it every time; it changes.
2. Follow it: templates, workflow, naming, the review checklist and the client email snippet all come from the doc.
3. Start from the templates the doc links (the Legal Templates folder). Never start from a past client's contract.
4. If the doc's title still says DRAFT, tell the user the process isn't confirmed yet and follow it anyway.

## Rules

- The doc wins over anything else: your memory, past contracts, or this skill. Don't keep your own copy of the process in memory or notes.
- If the Google Drive connector isn't available, say so and ask the user to turn it on. Don't work from memory instead.
- To change the process, propose the change to the user and suggest it as an edit on the doc for Sara to accept. Don't change this skill to carry process content.
