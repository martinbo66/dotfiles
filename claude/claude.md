# Global Claude Code Configuration

This file contains user-level instructions that apply to all Claude Code sessions across all projects.

## General Workflow Guidelines

### ALWAYS Check for Built-in Skills First

**CRITICAL RULE:** Before using manual Bash commands for common operations, ALWAYS check if a built-in skill exists.

**Process:**
1. When user requests a common operation (commit, PR, review, etc.)
2. **FIRST:** Check available skills using the Skill tool's list
3. **SECOND:** If a relevant skill exists, use the Skill tool to invoke it
4. **LAST RESORT:** Only use manual Bash commands if no skill exists

**Common operations with built-in skills:**
- Creating commits → Use `commit-commands:commit` skill
- Creating PRs → Use `commit-commands:commit-push-pr` skill
- Committing, pushing, and creating PR → Use `commit-commands:commit-push-pr` skill

**Why this matters:**
- Skills are purpose-built to handle edge cases correctly (e.g., ANSI escape sequences in PR descriptions)
- Skills provide consistent, tested workflows
- Manual commands are error-prone and require remembering complex flags/options

**Example of correct approach:**
```
User: "Create a pull request for the current branch"
❌ WRONG: Immediately run `gh pr create` commands
✅ CORRECT: Invoke the `commit-commands:commit-push-pr` skill using the Skill tool
```

**This applies to ALL projects and must be followed without exception.**

## Git and GitHub Guidelines

### Creating Pull Requests

**PREFERRED METHOD:** Use the built-in `commit-commands:commit-push-pr` skill via the Skill tool.

**FALLBACK METHOD (only if skill unavailable):** If you must use manual `gh` commands, always use the `NO_COLOR=1` environment variable to avoid ANSI escape sequences and control characters in PR descriptions.

**DO:**
```bash
# Use NO_COLOR=1 with --body for inline text
NO_COLOR=1 gh pr create --title "PR title" --body "## Summary

Your PR description here...

More content here..."
```

**DON'T:**
- ❌ Use `--body-file` (can capture terminal state and ANSI codes)
- ❌ Use command substitution with heredoc: `--body "$(cat <<'EOF' ...)"`
- ❌ Use `gh pr create` without `NO_COLOR=1` environment variable
- ❌ Pipe content into gh pr create

**Why:** The `gh` CLI can capture ANSI color codes and escape sequences from the terminal environment, resulting in unreadable PR descriptions with control characters like `[38;2;187;187;187m` scattered throughout the text.

### Verifying Clean PR Creation

**ALWAYS verify the PR is clean after creation** using actual byte inspection, not terminal display:

```bash
# Check the actual PR body bytes (replace PR_NUMBER with actual number)
gh api /repos/OWNER/REPO/pulls/PR_NUMBER --jq '.body' | od -c | head -20
```

**What to look for:**
- ✅ GOOD: Only plain text characters like `# S u m m a r y \n`
- ❌ BAD: Escape sequences like `\033` or `[38;2;` or `^[[`

**DO NOT verify with:**
- ❌ `gh pr view` - adds terminal colors for display (misleading)
- ❌ `gh pr view --json body` - still formats output with colors

**If escape sequences are found, fix immediately:**
```bash
# Fix with NO_COLOR environment variable
NO_COLOR=1 gh pr edit PR_NUMBER --body "Your clean text here"

# Verify again
gh api /repos/OWNER/REPO/pulls/PR_NUMBER --jq '.body' | od -c | head -20
```

**This applies to ALL projects and must be followed without exception.**
