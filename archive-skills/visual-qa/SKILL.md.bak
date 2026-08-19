---
name: visual-qa
description: Visual QA feedback loop using screenshots and computer use. Use after building UI to verify it looks right before committing.
trigger: After building or modifying UI components, pages, or layouts. Also /visual-qa or /vqa.
---

# Visual QA

Take screenshots to verify UI changes look correct before committing. This creates a feedback loop — build, screenshot, fix, repeat.

## Quick Check (Single Screenshot)

1. Use `/ss` to screenshot Chrome (requires Chrome to be open with the page)
2. Review the screenshot for:
   - Layout issues (overflow, alignment, spacing)
   - Missing responsive behaviour
   - Broken dark mode
   - Text truncation or wrapping issues
   - Wrong colors or contrast
3. Fix anything off, then screenshot again

## Full QA Flow

### Desktop check
1. Open the page in Chrome at normal width
2. `/ss` — screenshot desktop view
3. Review: layout, spacing, alignment, colors

### Mobile check
1. Open Chrome DevTools → toggle device toolbar → iPhone 14 (390px)
2. `/ss` — screenshot mobile view
3. Review: responsive layout, touch targets, bottom nav, text readability

### Dark mode check (if supported)
1. Toggle to dark mode
2. `/ss` — screenshot
3. Review: contrast, readability, no white-on-white or black-on-black

### Interactive check
Use computer use tools directly for interactive flows:
- `mcp__computer-use__screenshot` — capture current state
- `mcp__computer-use__left_click` — interact with elements
- `mcp__computer-use__scroll` — check scroll behaviour

## When to Use

- After building a new page or component
- After making layout changes
- After responsive design work
- After dark mode changes
- Before committing UI changes
- When debugging a visual bug reported by the user

## Automation

For repetitive checks, combine with development:
```
1. Make UI change
2. /ss to verify
3. If wrong → fix → /ss again
4. If right → commit
```

This is faster than alt-tabbing to check manually. Trust the screenshot — if it looks wrong in the screenshot, it looks wrong to users.
