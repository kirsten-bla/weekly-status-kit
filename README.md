# Weekly Status Kit

A Claude Code kit that drafts the weekly internal status update for a client project. It reads last week's entry from the status doc, collects this week's news from Jira, email, Slack and meeting notes, and drafts the new entry in the same format, ready to review and paste.

**Before:** about 45 minutes by hand. **With the kit:** a draft in about 5 minutes, and about 10 minutes of my time including review. See [`decisions.md`](decisions.md) for every run.

## Is this kit for you?

It fits if your week looks like this:

- A **Google Doc** holds the status updates: **one entry per week, newest first**, each with a bold date heading (`**Oct 13, 2026**`) and numbered items with **Done / In progress / Next / Blocked** lines.
- The work is tracked in **Jira**, with each status item mapped to an epic or tickets.
- News also comes in through **Gmail** (one label), **Slack** (one channel or DM) and **Granola** (one meeting folder).

If one of those is different (say, Linear instead of Jira, or no Granola), you'll need to change `references/sources.md` and the collector agent's tools, not just the config.

## What it does

```
/weekly-status [date]
 ├─ check-config.sh             stops if the kit isn't configured
 ├─ weekly-baseline-reader      reads last week's entry from the status doc (Google Drive)
 ├─ weekly-update-collector ×4  reads this week's Jira, email, Slack and Granola, in parallel
 ├─ main session                drafts the entry using rules.md + client-rules.md, checks it, shows it to you
 ├─ improve-skills              after the update is final, proposes lasting rule changes
 │    └─ skill-reviewer         decides which of your corrections should become rules
 └─ decisions.md                logs the run (items by id only) and what the next run must carry over
```

- **Draft only.** It never writes to the status doc unless you ask, and never sends anything.
- **Hooks enforce it.** `guard-client-writes.sh` always blocks sending, replying, forwarding and scheduling messages (except Slack to your own self-DM, used by the scheduled run). Every other connector write asks you first. `guard-secrets.sh` blocks reading or editing `.env` files, keys and credentials.
- **It learns from your corrections.** At the end of a run, `improve-skills` proposes new lines for `rules.md` or `client-rules.md` based on what you corrected. Nothing changes until you approve.
- **It remembers.** Every run is logged in `decisions.md`, and the next run picks up anything left to do.

## What you need

- Claude Code
- These claude.ai connectors, signed in: **Atlassian (Jira)**, **Gmail**, **Slack**, **Granola**, **Google Drive**
- `jq` (used by the hooks; on macOS: `brew install jq` if `jq --version` fails)
- Access to your project's status doc, Jira project, email label, Slack channel and Granola folder

## Configure before your first run

About 15 minutes. You only do it once per project.

### 1. Install

```bash
git clone <this repo> weekly-status-kit
cd weekly-status-kit
chmod +x scripts/*.sh .claude/hooks/*.sh
```

Connect the five connectors in claude.ai → Settings → Connectors, then start Claude Code here (`claude`). Run `/hooks` and check that both PreToolUse hooks are listed.

### 2. Create your three local files

These hold your project's data. They're **gitignored**, so they never end up in the shared repo.

```bash
cp kit.config.example kit.config
cp .claude/skills/weekly-status/references/items.example.md        .claude/skills/weekly-status/references/items.md
cp .claude/skills/weekly-status/references/client-rules.example.md .claude/skills/weekly-status/references/client-rules.md
```

### 3. Fill in `kit.config`

| Setting | Where to find it |
|---|---|
| `STATUS_DOC_ID` | The status doc URL: `docs.google.com/document/d/`**`<this part>`**`/edit` |
| `STATUS_DOC_HEADING` | Optional. The heading your weekly entries sit under, if the doc covers more than one project |
| `CLIENT_NAME` | How the update names the client ("Get approval from …") |
| `JIRA_SITE`, `JIRA_PROJECT` | Your Jira URL (`yourcompany.atlassian.net`) and the project key (`ABC`) |
| `JIRA_SPRINT_FIELD` | Usually `customfield_10010`. Not sure? Ask Claude: *"which field is the Sprint field in Jira project ABC?"* |
| `GMAIL_LABEL` | The Gmail label on the client's threads |
| `SLACK_CHANNEL_ID` | In Slack: open the channel → its name → About → the ID at the bottom (`C…` or `D…`) |
| `GRANOLA_FOLDER_ID` | Ask Claude: *"list my Granola folders with their IDs"* |

**Tip:** open Claude Code in this folder and say *"help me fill in kit.config"*. It can look up the Jira, Slack and Granola IDs through the connectors.

### 4. List your items in `items.md`

Replace the EXAMPLE rows with the items in your latest status entry: the same ids and titles as the doc, and each item's Jira epic or keys (`none` if it has none). After this, the skill keeps the file up to date.

### 5. Add client rules (optional)

In `client-rules.md`, keep the examples that apply to your client (who attends, what they don't want to see, wording) and delete the rest. An empty file is fine; `improve-skills` fills it as you correct drafts.

### 6. Check it

```bash
scripts/check-config.sh
```

It prints `OK`, or the list of what's still missing. The skill runs the same check first and won't start until it passes.

## Run it

In a **fresh session** (the kit keeps the status doc and raw sources out of your main context by design):

```
/weekly-status            # this week
/weekly-status 2026-10-12 # the week containing that date
```

You get:

1. **The entry**, ready to paste, in last week's format
2. **Review notes**: items closed or possibly closed, new items, findings kept out and why, and anything that couldn't be checked, each with its source

Correct anything in chat. When you say it's final (or ask it to write the entry to the status doc, and approve), it cleans up its working folder, runs `improve-skills` and logs the run in `decisions.md`. Fill in the time fields there.

## Run it automatically (optional, macOS)

Every Friday at 4 pm, a launchd job runs the skill headless. It only drafts: it saves the update and review notes to `drafts/weekly-status-<meeting date>.md` and posts them to a private Slack canvas, linked from a message in your self-DM. If the run fails, you get a short failure message there instead.

1. Fill in `SLACK_SELF_DM_ID`, `SLACK_USER_ID` and `CLAUDE_BIN` in `kit.config` (`which claude` gives the path).
2. `scripts/install-schedule.sh`
3. Test it now, without waiting for Friday: `launchctl kickstart gui/$(id -u)/com.weekly-status-kit`

The headless run can only use read-only connector tools plus local files; anything else is denied. If the Mac is asleep at 4 pm, the job runs when it wakes. Logs are in `drafts/logs/`. To stop it: `scripts/install-schedule.sh --remove`.

Review the draft, then finish in a normal session (corrections, writing to the doc).

## Compare it with a plain prompt

`prompts/brief.md` is the same task as one prompt, with no skill or agents. Fill in its `<…>` placeholders from `kit.config`, then run each in its own fresh session for the same week:

| | Brief alone | Kit |
|---|---|---|
| Start | paste the brief, adding "don't use skills or agents" | `/weekly-status <date>` |
| Measure | `/context` at start and when the draft appears, the time, and `/cost` | same |

Results are in `decisions.md`.

## Files

| Path | Shared? | What it is |
|---|---|---|
| `kit.config.example` → `kit.config` | example only | Your project's IDs and names |
| `.claude/skills/weekly-status/` | yes | The skill. `references/`: `sources.md` (what to read), `rules.md` (general rules) |
| `…/references/items.md`, `client-rules.md` | **no** (local) | Your items and client-specific rules, from the `.example.md` files |
| `.claude/skills/improve-skills/` | yes | Turns corrections into proposed rule changes |
| `.claude/agents/` | yes | Baseline reader, update collector, skill reviewer: read-only by design |
| `.claude/settings.json`, `.claude/hooks/` | yes | Client-write and secrets guards |
| `decisions.md` | yes | Run log and kit decisions: the kit's memory (items by id only) |
| `prompts/brief.md` | yes | The task as a single prompt, for comparison |
| `scripts/` | yes | Config check, scheduled run, schedule installer |
| `drafts/` | **no** (local) | Working files and scheduled drafts |
