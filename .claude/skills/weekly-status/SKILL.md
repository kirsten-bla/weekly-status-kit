---
name: weekly-status
description: >
  Drafts the weekly internal status update for a client project, building on last week's
  entry with this week's Jira, client email, Slack and Granola updates. Draft only, for review.
  Use when the user asks to prep or update the weekly status notes, or runs /weekly-status.
argument-hint: "[date in the week, e.g. 2026-10-12]"
disable-model-invocation: true
---

# Weekly status

You are the orchestrator. A baseline reader pulls last week's entry from the status doc, and four collector agents each read one source; you read what they return, and decide the final update. The user only needs that final update.

The update is a short, high-level report: where each item stands, not everything that happened. This skill only drafts. It never writes to the status doc and never sends anything.

Run it in the main session, not as a subagent, because it starts the collectors itself.

**Scheduled run:** when the prompt says this is a scheduled run, nobody is there to answer. Do steps 0 to 5, then save the update and the review notes to `drafts/weekly-status-<meeting date>.md` instead of showing them, and stop. Don't ask anything; if a step would ask the user (for example DATE MISMATCH), write the question at the top of that file and stop there. Then deliver it in Slack:

1. Create a canvas with `slack_create_canvas`, titled "Weekly status draft – <meeting date>". Lay it out like the status doc: `##` for each section, `###` for each item title, then bold **Done**, **In progress**, **Next**, **Blocked** labels with bullets under them. After a divider (`---`), add `## Review notes` with the notes as bullets.
2. Send one message to the user's self-DM with `slack_send_message`, `channel_id` = `SLACK_SELF_DM_ID` from `kit.config` (the only place the hook lets you send): "Weekly status draft for <meeting date> is ready: <canvas link>", plus one line with how many items closed, how many are new, and any source that couldn't be checked.

If the canvas fails, send the update and the review notes as messages to the self-DM instead: the update first, the review notes as a thread reply, each under 5,000 characters, split at an item boundary. Don't edit `items.md` in a scheduled run; list the changes it needs under **Carry over** in step 8. Skip step 7: the user reviews it later and finishes the run in a normal session. Do step 8.

## Files

- `kit.config` (repo root): this project's IDs and names. Fills the `{CAPS}` placeholders.
- `references/sources.md`: what to read, with exact tools and filters
- `references/rules.md`: how to decide the final update (general)
- `references/client-rules.md`: rules for this client only; they win over `rules.md`
- `references/items.md`: each item's Jira epic or keys
- `decisions.md` (repo root): the run log. Read the newest entry in step 1, add one in step 8.

Created during the run in `drafts/weekly-status-work/`, and deleted at the end:

- `baseline.md`: last week's entry (step 2)
- `brief-<source>.md`: what each collector should read (step 3)
- `report-<source>.md`: what each collector found (step 3)

## Steps

### 0. Check the setup

Run `scripts/check-config.sh` (add `--scheduled` in a scheduled run). If it doesn't print `OK`, stop and show the user its output and the README section "Configure before your first run". Don't guess missing values, and don't run with the example items.

Then read `kit.config`. Every `{CAPS}` placeholder in the references and briefs is filled from it.

### 1. Work out the week

Use the week the skill runs in, Monday to Friday. If the user gave a date (`$ARGUMENTS`), use the week that contains it.

Fill in the date placeholders from `sources.md`: `{start}` (Monday), `{end}` (Friday) and `{after}` (Saturday). The **meeting date** is the Monday after `{end}`.

Read the newest entry in `decisions.md`. If it has **Carry over** lines (for example, changes a scheduled run couldn't make to `items.md`), apply them now, except in a scheduled run, where you only repeat them in the review notes.

Create a working folder, `drafts/weekly-status-work/`. If it already exists from an earlier run, empty it first. Everything this run needs goes there, and the folder is deleted at the end (step 7).

### 2. Read last week's entry

Don't read the status doc yourself; it holds every past week and would fill this session's context. Start one `weekly-baseline-reader` agent and give it, in its prompt, the "Status doc (baseline)" section of `sources.md` with the placeholders filled in, and the meeting date. It returns only the newest entry.

If its STATUS isn't OK, stop and tell the user what it said. For DATE MISMATCH, ask them which entry to use, then start the reader again with that entry date in its prompt. Otherwise save the ENTRY, as returned, as `baseline.md` in the working folder. This is the baseline: it is both the starting point and the format to follow.

From it, make the item list: each item's id, title, Jira keys from `items.md`, and one line on where it stood. If an item is missing from `items.md`, look up its Jira epic or keys and add them (or `none`).

### 3. Start the four collectors

For each source (Jira, Email, Slack, Granola), write a brief to the working folder, e.g. `brief-jira.md`, with only:

- its own section of `sources.md`, with the placeholders and dates filled in
- the week (`{start}` to `{end}`)
- the item list from step 2

Then start four `weekly-update-collector` agents in parallel, in one message, and point each one to its brief file. Each collector returns its report as its final message; collectors have read-only tools by design, so don't give them write access. Save each one, as returned, to `report-<source>.md` in the working folder.

When all four are done, check that the four report files exist. If a collector fails or its report is empty, try it once more. If it fails again, carry on without it and say so in the review notes.

### 4. Decide the final update

Read `rules.md`, `client-rules.md`, `baseline.md` and the four reports from the working folder. Then go item by item through the baseline and decide where each one stands now:

- Line up the item's findings from all reports by date, and apply "Dates and sources" in `rules.md`. Combine findings that say the same thing.
- Work out a release date where `rules.md` asks for one.
- Add new items only when the reports show real new work, and add them to `items.md`. Remove closed items from `items.md` the week they drop off.

Write the entry in the same format and at the same level as the baseline: same sections, same item titles, short lines, no ticket detail. Put the meeting date at the top.

### 5. Check it

Before showing it, check against the baseline, `rules.md` and `client-rules.md`:

- Every item from last week is there, or marked Closed with a source showing it closed.
- Everything finished or sent this week is covered by a Done line, or deliberately left out.
- Each item has only Done, In progress, Next or Blocked lines, in that order.
- Lines follow "Keep it short" in `rules.md`: active items say what, who and when; no Done line from last week was dropped unless the item closed.
- Every In progress and Next line on an item with Jira tickets matches Jira and the sprint plan (only what's in this week's sprint is called "this week"); every date is a start or release date, with its working-out in the review notes if projected.
- Nothing from the "Leave out" lists, and no end users' names, emails or IDs.
- No quotes from the collector reports in the entry. Quotes are only for checking findings; they may appear in the review notes.
- The entry is about as long as last week's. If it is much longer, cut it down.

Fix anything that fails.

### 6. Show it

Show the user:

1. the final update, ready to paste
2. the review notes (see `rules.md`), each with its source

Say that nothing was written to the status doc.

### 7. Take corrections, then clean up

When the user corrects the update, show the corrected version.

When the user says the update is final, or once the update has been written to the status doc in Google Docs at the user's request, delete `drafts/weekly-status-work/` without asking and confirm it's gone. If the session ends before that, the next run empties the folder in step 1.

Then run the `improve-skills` skill for `weekly-status`. It checks this session's corrections and proposes any that should become lasting changes, such as a line for `rules.md` or `client-rules.md`.

### 8. Log the run

Add an entry at the top of "Runs" in `decisions.md`, in the format shown there. `decisions.md` is shared with the kit, so name items by id only ("2iii"): no client, people or product names, no ticket keys, nothing from the entry itself. Include:

- the date, the week, and whether it was scheduled or interactive
- counts: items carried, closed and new; any source that failed
- the user's corrections, one short line each, and what `improve-skills` changed (or "none")
- what broke or needed a workaround
- **Carry over:** anything the next run must do (changes to `items.md`, an item to drop next week), or "none"

Leave the time fields as `_` for the user to fill in. Tell the user the run is logged.
