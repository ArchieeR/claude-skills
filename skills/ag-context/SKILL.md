---
name: ag
description: Import Antigravity conversation context for LLM counsel. Use when you want Claude to review or discuss decisions made in an Antigravity session.
---

# Antigravity Context Import

This skill imports context from an Antigravity (Google Gemini CLI) conversation so you can discuss it with Claude - getting a second LLM perspective on decisions.

## How to Use This Skill

When the user invokes `/ag`, follow these steps:

### Step 1: List Recent Conversations

Run this command to get the 5 most recent Antigravity conversations:

```bash
for id in $(ls -t ~/.gemini/antigravity/conversations/*.pb 2>/dev/null | head -5 | xargs -I {} basename {} .pb); do
  task_file="$HOME/.gemini/antigravity/brain/$id/task.md"
  if [ -f "$task_file" ]; then
    title=$(grep -m 1 "^#\|^[A-Za-z]" "$task_file" 2>/dev/null | head -1 | sed 's/^#* *//' | cut -c1-60)
  else
    title="(no task summary)"
  fi
  mod_time=$(stat -f "%Sm" -t "%b %d %H:%M" "$HOME/.gemini/antigravity/conversations/$id.pb" 2>/dev/null)
  echo "$id | $mod_time | $title"
done
```

### Step 2: Present Options to User

Use AskUserQuestion to present the conversations as options. Format them nicely with the timestamp and title.

### Step 3: Extract Context

Once the user selects a conversation, extract its context:

```bash
SELECTED_ID="<conversation_id>"
BRAIN_DIR="$HOME/.gemini/antigravity/brain"
CONV_DIR="$HOME/.gemini/antigravity/conversations"
OUTPUT="/tmp/ag-context.md"

{
  echo "# Antigravity Conversation Context"
  echo "**ID:** $SELECTED_ID"
  echo ""

  # Task
  if [ -f "$BRAIN_DIR/$SELECTED_ID/task.md" ]; then
    echo "## Task"
    cat "$BRAIN_DIR/$SELECTED_ID/task.md"
    echo ""
  fi

  # Implementation Plan
  if [ -f "$BRAIN_DIR/$SELECTED_ID/implementation_plan.md" ]; then
    echo "## Implementation Plan"
    cat "$BRAIN_DIR/$SELECTED_ID/implementation_plan.md"
    echo ""
  fi

  # Resolved tasks
  for f in "$BRAIN_DIR/$SELECTED_ID"/task.md.resolved*; do
    if [ -f "$f" ]; then
      echo "## Progress: $(basename $f)"
      cat "$f"
      echo ""
    fi
  done

  # Conversation excerpts
  if [ -f "$CONV_DIR/$SELECTED_ID.pb" ]; then
    echo "## Conversation Excerpts"
    echo '```'
    strings "$CONV_DIR/$SELECTED_ID.pb" 2>/dev/null | grep -E "^[A-Za-z].{30,200}$" | head -100
    echo '```'
  fi
} > "$OUTPUT"

cat "$OUTPUT"
```

### Step 4: Read and Summarize

Read the output file at `/tmp/ag-context.md` and provide a brief summary of:
- What the conversation was about
- Key decisions or implementations made
- Any open questions or issues

### Step 5: Ready for Discussion

Tell the user you now have the context and ask what they'd like to discuss or get a second opinion on.

## Example Flow

User: `/ag`

Claude:
1. Lists 5 recent conversations
2. "Which Antigravity conversation would you like me to review?"
3. User picks one
4. Claude extracts and reads context
5. "I've loaded the context from your GEO Phase 2 session. You worked on bot detection middleware, Amplitude tracking, and SVG optimization. What would you like to discuss?"
