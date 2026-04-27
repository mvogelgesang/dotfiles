---
name: sync-gdoc
description: >
  Use this skill when the user wants to mirror a Google Drive document into
  the local notebook as a read-only markdown file with a daily auto-sync cron
  job. Trigger phrases: "sync this Google doc", "mirror this doc locally",
  "add this to my notebook", "keep this doc in sync", "set up a local mirror".
allowed-tools:
  - mcp__plugin_google_google__docs_get
  - Bash
  - Write
  - CronCreate
  - CronDelete
  - CronList
---

# Skill: sync-gdoc

Mirror a Google Drive document into the local notebook as a read-only markdown
file, then schedule a daily cron job to keep it in sync automatically.

## Arguments

Usage: `/sync-gdoc <file-id> [local-subfolder]`

- `$1` — Google Drive file ID (required). The long string in the Drive URL
  between `/d/` and `/view` or `/edit`.
- `$2` — Local subfolder within the notebook (optional, default: infer from
  doc title or use root). Example: `mcp`, `sales`, `engineering`.

If no arguments are provided, ask the user for the Google Drive file ID and
desired subfolder before proceeding.

## Steps

### 1. Fetch the document

Use `mcp__plugin_google_google__docs_get` with the provided file ID to retrieve
the full document content, including all tabs.

Note the document title from the returned content — the local filename must
match the Google Drive filename exactly (e.g.
`HOME - Salesforce MCP Server Registration for ISVs.md`).

### 2. Determine the local path

- Notebook root: `~/.aisuite/notebook/`
- If `$2` is provided: `~/.aisuite/notebook/$2/<Google Drive filename>.md`
- If `$2` is not provided: `~/.aisuite/notebook/<Google Drive filename>.md`

Create the subfolder if it does not exist:
```bash
mkdir -p ~/.aisuite/notebook/$2
```

### 3. Write the local file

Write the file with the following structure:

```
# <Document Title>

> **Source:** [Google Drive](https://drive.google.com/file/d/<file-id>/view)
> **File ID:** `<file-id>`
> **Auto-synced daily. Do not edit manually.**

---

<content with all tabs flattened — each tab becomes a ## section using the tab name as heading>
```

Rules for flattening:
- Each tab becomes a `##` section with the tab name as the heading
- Preserve all links, lists, and sub-headings from the original
- Do not truncate or summarise — capture the full content of every tab

### 4. Set the file to read-only

```bash
chmod 444 "<full local path>"
```

Verify with `ls -l "<full local path>"` — permissions should show `-r--r--r--`.

### 5. Commit the initial file

```bash
cd ~/.aisuite/notebook
git add -A
git commit -m "docs(<subfolder>): add local mirror of <document title>"
git push github main
```

### 6. Schedule the daily sync cron job

Use `CronCreate` with these parameters:
- `cron`: `17 7 * * *` (7:17 AM daily — offset from the hour to avoid congestion)
- `durable`: `true`
- `recurring`: `true`
- `prompt`: Use the exact template below, substituting `<file-id>`, `<document title>`, and `<full local path>`:

```
Sync the Google Drive doc "<document title>" (file ID: <file-id>) to the local notebook.

Steps:
1. Fetch the latest content using mcp__plugin_google_google__docs_get with file_id `<file-id>`
2. Temporarily unlock the file: `chmod 644 "<full local path>"`
3. Rewrite the file at `<full local path>` with updated content, preserving the header:
   > **Source:** [Google Drive](https://drive.google.com/file/d/<file-id>/view)
   > **File ID:** `<file-id>`
   > **Auto-synced daily. Do not edit manually.**
   Flatten all tabs into ## sections using the tab name as the heading.
4. Re-lock the file: `chmod 444 "<full local path>"`
5. Check for changes: `cd ~/.aisuite/notebook && git diff --stat`
6. If changed: `git add -A && git commit -m "chore(<subfolder>): sync <document title> from Google Drive"` then `git push github main`
7. If unchanged: stop silently.

Report what changed or confirm no updates were needed.
```

### 7. Report back to the user

Summarise what was done:

| Property | Value |
|----------|-------|
| **Google Doc** | `<document title>` |
| **File ID** | `<file-id>` |
| **Local path** | `<full local path>` |
| **Permissions** | `444` (read-only) |
| **Sync cron** | `<cron job ID>` — daily at 7:17 AM |
| **Auto-commit** | Picked up by existing hourly cron |

Remind the user that:
- The cron job expires after **7 days** — they will be prompted to renew it
- All edits should be made in **Google Drive** — local changes will be overwritten
- To manually re-sync at any time, they can run `/sync-gdoc <file-id>` again
