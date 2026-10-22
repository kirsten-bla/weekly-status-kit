# Decisions and runs

The kit's memory. The skill reads the newest run's **Carry over** at the start of each run (step 1) and adds a run at the end (step 8). Times are filled in by hand.

This file is shared with the kit: items by id only. No client, people or product names, no ticket keys, nothing copied from the status entry.

## Kit decisions

| Date | Decision | Why |
|---|---|---|
| 2026-10-17 | The baseline reader finds the entry with Grep, then reads only those lines of the saved file | The status doc holds every past week and was too big to read in one go |
| 2026-10-17 | Collectors run on Haiku, one per source, in parallel; the main session only sees their short reports | Keeps raw emails, tickets and transcripts out of the main context |
| 2026-10-20 | Scheduled runs don't edit `items.md` or clean up; they list the changes as Carry over for the next run | Nobody is there to approve edits in a headless run |
| 2026-10-21 | Split the kit into shared logic and local config (`kit.config`, `items.md`, `client-rules.md`), with a setup check before each run | So the kit can be shared without client data, and a teammate can't run it half-configured |
| 2026-10-21 | Added a hook that blocks reading or editing secrets | Course safety bar; the kit never needs them |

## Runs

Newest first.

### 2026-10-21 · week Oct 19–23 · interactive (comparison: kit vs brief alone)

- **Draft ready:** _ · **My time:** _ · **Start to finish:** _
- **/context at draft:** kit _ · brief alone _
- **Items:** _ carried, _ closed, _ new · **Sources failed:** _
- **Corrections:** _
- **improve-skills:** _
- **What broke:** the brief alone stopped to ask which entry to use as the base (the newest entry was dated this week's Monday); the kit didn't need to ask, because it works out the meeting date
- **Carry over:** _

### 2026-10-20 14:15 · week Oct 19–23 (2 days in) · scheduled (second run)

- **Draft ready:** delivered to Slack self-DM · **My time:** _ · **Start to finish:** _
- **Items:** 3 moved (one to In progress, one to Done, one with a new date) · **Sources failed:** none
- **Flagged for review:** one item with dates that disagreed (Jira vs a meeting), so it followed Jira; one item called complete in a meeting but still To do in Jira, so it was kept open; an item title looked like it held an ID and was made generic
- **What broke:** couldn't edit `items.md` or empty the working folder (by design in scheduled runs); the Jira collector didn't read ticket comments, and read only the first page of tickets under 4 epics
- **Carry over:** remove 1D and 1G from `items.md`; remove 4B the week after

### 2026-10-20 13:00 · week Oct 19–23 (2 days in) · scheduled (first run)

- **Draft ready:** delivered to Slack self-DM (canvas) · **My time:** _ · **Start to finish:** _
- **What broke:** _ (draft later overwritten by the 14:15 run at the same path; the Slack copy was kept)

### 2026-10-17 · week Oct 12–16 · interactive (first real run)

- **Draft ready:** 5 min · **My time:** ~10 min · **Start to finish:** ~22 min · **By hand before the kit:** ~45 min
- **What broke:** the baseline reader couldn't read the large status doc (fixed: it now reads the saved file with Grep and Read); two Jira tickets were missing from search
- **Carry over:** none
