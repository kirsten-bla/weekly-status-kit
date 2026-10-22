# Rules

How to turn last week's entry and this week's findings into the new entry. These are the general rules; client-specific ones (names, wording) are in `client-rules.md` and win where they disagree. Add to the right file whenever the user corrects a draft.

## Keep it short

The update is covered in a 30-minute meeting. Every line is short and to the point.

- **Items being worked on or starting soon:** what we're working on, who is on it (BE, iOS, Android, Web, QA), and when it could be released.
- **Everything else** (waiting, blocked, not prioritized, no updates): keep its existing lines, including Done; any new information is one short line.

## What stays and what goes

- **An item stays until it is closed.** Carry every item from last week's entry forward, even with no news.
- **No news:** add " - (no updates)" after the item title and keep its lines as they were. A start or release date that moved in Jira counts as news.
- **Closed:** an item is closed only when a source shows it (released or confirmed done). Add " - Closed" after the title for one week, with a one-line reason. Drop it the week after.
- **Next was "Close":** if last week's Next was "Close" and the item's Jira tickets are Done, mark it Closed this week. Don't hold it open over an older or loosely linked finding; put that in the review notes.
- **Ready to close but not confirmed:** keep the item and put the reason it may close in the review notes, not in the entry.
- **New items:** add them at the end of the section they belong to, with " (new)" after the title. Only add work that someone actually asked for, started or decided this week.
- A finding goes into the entry only if the source states it plainly. If the collector inferred the link to an item, or it is the only source for a new item, put it in the review notes and let the user decide. A match through the item's Jira keys (`items.md`) is not inferred.

## Dates and sources

- Every finding has a date. When findings conflict, the newest one is the update; drop the older one.
- Same date: Jira over email, Slack or meetings.
- When an item has Jira tickets, In progress and Next come from them. Email, Slack and meetings add only decisions, blockers and dates.
- Read relative dates from the day they were written: "next week" in a message from the week of `{start}` becomes "this week" on the meeting date. If you're not sure, give the date ("week of Oct 19").

## Writing each item

- Keep the item's title and letter or numeral from last week.
- Use only these lines, in this order: **Done**, **In progress**, **Next**, **Blocked**. Leave out any that are empty.
- **Done** is what finished this week, summed up per item in plain words: a ticket moved to Done, something we sent (an estimate, report or plan), a release, or a confirmed decision. No ticket list, no dates. Ready for Test is In progress; Needs Feedback is Blocked.
- Keep last week's Done lines as they are. Update the other lines; don't add a new line for each week. Move a Next to Done only when a source from the week shows it happened.
- **Next** is one line: who starts what, and when. Never list tasks or tickets. Use the case that fits:
  - **In a sprint:** name what actually starts in this week's sprint in plain words ("iOS integration and the BE contract"), not just the team, so a small piece doesn't read as the whole build. If nothing is in this week's sprint, say when the first sprint starts instead. Then give one release date: the end of the sprint holding the last or release ticket. Don't list the later sprints.
  - **Prioritized, waiting on client approval:** when a source shows we decided to prioritize the item but the client hasn't approved the scope or estimate yet, Next is: "Get approval from {CLIENT_NAME}; work could start <week> and end <date>." Start = the start of the first sprint holding the item's tickets; end = the end of the sprint holding the last ticket.
  - **Not prioritized:** Blocked says "prioritize to include in the sprint". Never write "can start if prioritized" for work already in a sprint.
- **Dates** look forward only: when work starts and when it could be released, never when something was done. Write plain dates, never sprint names or "the sprint ending…": "starts the week of Oct 26", "release targeted for Nov 20".
- Quote an estimate only if it's in something we sent or in Jira. Never take estimate figures from meeting notes or Slack alone; if unsure, write "estimates sent" without numbers.
- Say "done, not released" when a ticket is done but not released.
- Plain language. No ticket keys unless the user asks for them.

## Leave out

- Personal data: names, emails and IDs of the product's end users (patients, customers). Use counts or roles ("a user at one clinic").
- Contract, SOW and hours billed. Estimates can stay (see "Writing each item"). Which team is on an item stays in.
- Internal dev work the client doesn't need: environment builds, merges between branches, test builds.

## Review notes

Show these with the draft, never inside the entry:

- Items closed this week, and why
- Items that may be ready to close
- New items added
- Findings kept out of the entry because the link to an item was inferred, or only one source mentions a new item
- Tickets not in any sprint yet, for items waiting on approval
- How each projected start or release date was worked out (estimates, hours per day, assumptions)
- Anything a reader could not check (a source that failed, a folder with no meetings)
