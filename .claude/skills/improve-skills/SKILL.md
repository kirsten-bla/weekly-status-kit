---
name: improve-skills
description: >
  Looks at the corrections the user made to a skill's output in this session and proposes
  lasting changes to that skill's files (its rules, references or steps). Proposes only;
  changes nothing until the user agrees. Often finds nothing to change, and says so. Use when
  a skill's last step says to run it (e.g. weekly-status after the update is written to the
  status doc), or when the user runs /improve-skills or asks to "save what we learned" for a skill.
argument-hint: "[skill name]"
---

# Improve skills

You turn this session's corrections into lasting changes to a skill, so the user doesn't have to make the same correction next time. Most sessions need no change. Saying "nothing to change" is a good result.

Run it in the main session: you need the conversation to see what the user corrected.

## Steps

### 1. Pick the skill

Use the skill in `$ARGUMENTS`. If none was given, use the skill that ran in this session. If more than one ran, ask which.

### 2. Find the corrections

Go through this session and list what the user corrected in the skill's output: something changed, removed, added or rejected, or anything said with "always", "never" or "don't". Quote the user's own words.

Leave out:

- one-off content calls that only apply to this run ("exclude 1G this week")
- typos and small wording fixes with no pattern
- things the skill got right

If nothing is left, say "No improvements from this session" and stop.

### 3. Have them reviewed

Don't read the skill's files yourself; that keeps them out of this session's context. Start one `skill-reviewer` agent and give it, in its prompt:

- the skill name and its folder (`.claude/skills/<name>/`)
- the list from step 2, each correction with the user's words

It reads the skill, decides each correction, and returns exact proposed edits or "no change". It writes nothing.

If it fails or returns nothing, try once more. If it fails again, tell the user and stop.

### 4. Show them

If PROPOSALS is "none", say "No improvements from this session", show the NOT CHANGING list, and stop.

Otherwise show a numbered list. For each proposal:

- the correction, quoting the user
- the file and section
- the exact text: current line → new line, or the new line
- why, in one line

Then the "Not changing" list, and anything under NOTES. Say that nothing has been changed yet.

### 5. Apply what the user approves

Apply only the proposals the user approves, exactly as shown. Then list the files changed.

Only edit the skill's own folder and the instructions of agents it starts. Never change an agent's tools or model, `settings.json`, hooks, or `CLAUDE.md`. If a change belongs there, say so and leave it to the user.
