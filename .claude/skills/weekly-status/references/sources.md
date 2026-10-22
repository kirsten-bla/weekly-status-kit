# Sources

Exactly what to read and how to filter it. The weekly-baseline-reader gets the "Status doc (baseline)" section; each weekly-update-collector run gets only its own source's section, with the placeholders filled in.

Placeholders in `{CAPS}` come from `kit.config` at the repo root. Don't put real IDs in this file.

## Dates

Every filter below uses the same week:

| Placeholder | Value | Example (week of Oct 12) |
|---|---|---|
| `{start}` | Monday of the week | 2026-10-12 |
| `{end}` | Friday of the week | 2026-10-16 |
| `{after}` | the Saturday after `{end}` (for "before" filters, which exclude the day given) | 2026-10-17 |

## Status doc (baseline)

- **Tool:** Google Drive `read_file_content`
- **File ID:** `{STATUS_DOC_ID}`
- **What to keep:** the text from the first date under the heading "{STATUS_DOC_HEADING}" (or from the top of the doc, if no heading is set) down to, but not including, the second date. That is last week's entry. Ignore the rest of the doc.
- **Finding the dates:** date headings are bold (`**Oct 13, 2026**`) and may start with spaces, so allow leading whitespace when searching for them. Before using an entry, check that its date is the Monday before the meeting date. If it isn't (a gap, or the meeting date's entry already exists), report DATE MISMATCH.

## Jira

- **Tool:** Atlassian `searchJiraIssuesUsingJql`, then `getJiraIssue` for each result to read comments
- **Site:** {JIRA_SITE}
- **JQL:** `project = {JIRA_PROJECT} AND updated >= "{start}" AND updated < "{after}" ORDER BY updated DESC`
- **Finished:** also run `project = {JIRA_PROJECT} AND status changed to Done DURING ("{start}", "{after}")` and report every result under its item, or under "New or unmatched"
- **Comments:** only those posted between `{start}` and `{end}`
- **Mapped items:** for each item with keys in the item list, also read the whole epic (`parent = <epic>`, any status, any update date). A ticket's current status beats a comment describing planned work.
- **Sprints:** run `project = {JIRA_PROJECT} AND (sprint in openSprints() OR sprint in futureSprints())` with fields `summary`, `status`, `parent` and `{JIRA_SPRINT_FIELD}` (the Sprint field: name, state, start and end dates). This returns the active sprint and every planned one, so group the tickets by sprint. "This week's sprint" is the sprint whose start and end dates include the meeting date (the Monday after `{end}`). Sprints can be one or two weeks long, so it may have started the week before.
- **Plan line:** from the mapped items and sprints, write a Plan line for every item with Jira keys, even if nothing moved. It holds what is left, as described under "Plan line" in your instructions.

## Email

- **Tool:** Gmail `search_threads`, then `get_thread` with `PLAIN_TEXT`
- **Query:** `label:{GMAIL_LABEL} after:{start} before:{after}` (dates as `YYYY/MM/DD`)
- **Messages:** read the whole thread; report only messages sent between `{start}` and `{end}`

## Slack

- **Tool:** Slack `slack_read_channel`, then `slack_read_thread` for messages with replies
- **Channel:** `{SLACK_CHANNEL_ID}`
- **Filter:** `oldest` = `{start}` 00:00 and `latest` = `{after}` 00:00, as Unix timestamps in local time

## Granola

- **Tools:** Granola `list_meeting_folders`, `list_meetings`, `get_meetings`
- **Folders:** `{GRANOLA_FOLDER_ID}` plus every folder whose `parent_folder_id` is that ID. Look the subfolders up on each run.
- **Filter:** `list_meetings` once per folder with `folder_id`, `time_range: custom`, `custom_start: {start}`, `custom_end: {end}`
- **Read:** `get_meetings` for every meeting found. Use `get_meeting_transcript` only when the notes are missing something needed.
