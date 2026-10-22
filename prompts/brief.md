Draft this week's entry (Mon <MON> – Fri <FRI>, meeting <MEETING>) for the internal status doc, ready for me to review and paste. Draft only: don't write to the doc, send anything or change any ticket.

**Context:** The status doc is a Google Doc with one entry per week, newest first. Copy last week's entry as the base and format: same sections, items and titles. It's read in a 30-minute client meeting, so each item says where it stands now, in short plain lines.

**Sources** (read only this week):
- Status doc: Google Drive `read_file_content`, ID `<STATUS_DOC_ID>`. Use only the newest entry under "<STATUS_DOC_HEADING>".
- Jira: `searchJiraIssuesUsingJql`, `project = <JIRA_PROJECT> AND updated >= "<MON>" AND updated < "<SAT>"`; then `getJiraIssue` for each item's tickets. Sprints: `sprint in openSprints() OR sprint in futureSprints()`, field `<JIRA_SPRINT_FIELD>`.
- Email: Gmail `search_threads`, `label:<GMAIL_LABEL> after:<MON> before:<SAT>`, then `get_thread`.
- Slack: `slack_read_channel`, channel `<SLACK_CHANNEL_ID>`, plus `slack_read_thread`.
- Meetings: Granola `list_meetings`, folder `<GRANOLA_FOLDER_ID>` and subfolders, then `get_meetings`.

**Rules:**
- Keep every item. No news: add "- (no updates)". Closed only when a source shows it; new items only for work asked for, started or decided this week.
- Lines per item: Done, In progress, Next, Blocked, in that order. Jira decides In progress and Next; other sources add decisions, blockers and dates. Newest finding wins.
- Next = who starts what, and when; one forward release date, no sprint names.
- Leave out: end users' personal data, ticket keys, contract/SOW/hours billed, internal dev work.

**Done when:** every item from last week is there or marked Closed with a source; dates look forward; nothing from "Leave out"; about as long as last week. Give me the entry plus review notes with a source for each finding.

If a source fails, say so and continue. If last week's entry has the wrong date, ask me which to use. If unsure where a finding belongs, put it in the review notes.
