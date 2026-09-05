---
name: remember
description: Save a Jira ticket decision, context note, or key fact directly to the configured private GBrain knowledge base. Use when asked to remember ticket context or called by another ticket workflow.
user-invocable: true
argument-hint: "[ISSUE-123] [note text]"
---

# Remember

Save durable ticket context to GBrain. The configured private brain is the destination; `~/agents` can point into a public configuration repository. Never write ticket content to `~/agents/memory`, its `MEMORY.md`, or another file in the configuration repository, including temporary files. This skill does not also write Claude auto-memory.

## Invocation

- `/remember` — infer the issue from the branch and the note from the conversation.
- `/remember ISSUE-123` — use that issue and derive the note from context.
- `/remember <note>` — infer the issue and save the supplied note.
- `/remember ISSUE-123 <note>` — use both explicit values.

Other skills can supply the issue key, origin context, and preservation branch. Preserve this calling convention.

## Workflow

### 1. Resolve the issue and note

Use the explicit issue key, then the current conversation or `git branch --show-current`. Ask only if the issue is still ambiguous. Use the user's note when supplied; otherwise capture the meaningful decision, rationale, scope change, or discovered constraint from context. Ask if there is no meaningful note to derive.

Keep each entry concise, normally two sentences. Preserve exact branch names and relevant caveats for deferred work. Do not infer decisions the user has not made or store credentials.

### 2. Find the existing knowledge

Use GBrain MCP tools when available. For CLI fallback, supply the runtime path:

```bash
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"
```

Use the equivalent `gbrain` CLI operation, consulting its help for the installed version's arguments.

Search the exact issue key with `search`; also check the legacy token `jira_<KEY>` when necessary. Read relevant pages, rather than treating a search snippet or similar score as a match. Resolve matching pages in the configured private source; do not select an unrelated federated source for writes.

Prefer the existing maintained page for the exact issue. Imported source pages and session transcripts are supporting evidence, not the maintained destination. If only those exist, preserve them and create a subject page linked to that evidence. Consult the brain's `RESOLVER.md`, relevant directory README, and active schema to select a stable, subject-based slug and valid type. Include the exact issue key in the title and aliases so `/getcontext` can find it.

During migration, read `~/agents/memory/jira_<KEY>.md` if it exists. Reconcile unique origin context, preservation branches, and decisions into the brain page; do not copy its index or overwrite newer brain knowledge with older notes. Retain dates and attribution and identify unresolved conflicts. Leave the legacy file unchanged.

Fetch missing ticket metadata only when needed, using the installed Jira access skill. A Jira failure need not block saving a clear user-provided decision for a known issue; omit unverified metadata.

### 3. Write the brain page

For an existing page, call `get_page` with `include_content: true`, edit the canonical `content`, and pass the complete result to `put_page` with the same slug. Preserve frontmatter, unrelated sections, source links, and timeline markers. Avoid duplicate entries when the same decision is already recorded; make genuine corrections explicit and dated.

For a new page, include the issue key, known summary, origin context, any preservation branch, and dated decisions with inline provenance such as `[Source: User, YYYY-MM-DD, current conversation]`. Link related project and evidence pages using the brain's relative-link conventions. Do not invent a ticket title or project relationship.

Prefer `put_page` with structured content. If using `gbrain capture --file`, create a private temporary file outside all public repositories, pass the explicit resolved `--slug` and schema-valid `--type`, and remove that temporary file after confirmed capture. Never use the content-hash default slug for an editable ticket page.

If the brain lookup or write fails, report that the note was not saved. Do not fall back to public memory files or claim success. If a write's outcome is uncertain, re-read the target before retrying to avoid duplicate decisions.

### 4. Verify and confirm

Read the saved page back and check that the new decision and any carried-forward context are present. Confirm the issue key and brain page, with a verified link when available. Distinguish successful brain persistence from any pending or failed Git-mirror push; do not claim that all machines or the remote repository have synchronized without evidence.

The Claude Stop hook mirrors separate auto-memory writes. It is not required for this skill's direct GBrain writes, and this skill does not install, disable, or modify it.
