#!/usr/bin/env bash
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
source_pane="${HERDR_PANE_ID:-}"
review_pane=""
worktree_created=false

die() {
  printf 'pr-review: %s\n' "$*" >&2
  exit 1
}

cleanup_on_failure() {
  status=$?

  if [[ "$status" -ne 0 ]]; then
    if [[ -n "$review_pane" ]]; then
      "$herdr" pane close "$review_pane" >/dev/null 2>&1 || true
    fi

    if [[ "$worktree_created" == true ]]; then
      git -C "$repo_root" worktree remove "$review_dir" >/dev/null 2>&1 || true
    fi
  fi

  exit "$status"
}

trap cleanup_on_failure EXIT

for command in git gh jq; do
  command -v "$command" >/dev/null 2>&1 ||
    die "required command not found: $command"
done

[[ -n "$source_pane" ]] ||
  die "this action must be invoked from a Herdr pane"

# A link-handler invocation provides this variable. A keybinding invocation
# falls back to the macOS clipboard.
pr_url="${HERDR_PLUGIN_CLICKED_URL:-}"

if [[ -z "$pr_url" ]] && command -v pbpaste >/dev/null 2>&1; then
  pr_url="$(pbpaste)"
fi

# PR URLs cannot contain whitespace.
pr_url="$(printf '%s' "$pr_url" | tr -d '[:space:]')"

[[ -n "$pr_url" ]] ||
  die "Ctrl-click a PR URL or copy one before invoking the action"

if [[ "$pr_url" =~ ^https://github\.com/([^/]+)/([^/]+)/pull/([0-9]+)([/?#].*)?$ ]]; then
  owner="${BASH_REMATCH[1]}"
  repository="${BASH_REMATCH[2]}"
  pr_number="${BASH_REMATCH[3]}"
else
  die "clipboard/link is not a supported GitHub PR URL: $pr_url"
fi

pr_slug="$owner/$repository"

# Find the repository associated with the pane that invoked the action.
pane_json="$("$herdr" pane get "$source_pane")"
pane_cwd="$(
  printf '%s' "$pane_json" |
    jq -r '.result.pane.foreground_cwd // .result.pane.cwd // empty'
)"

[[ -n "$pane_cwd" ]] ||
  die "Herdr could not determine the focused pane's working directory"

repo_root="$(
  git -C "$pane_cwd" rev-parse --show-toplevel 2>/dev/null
)" || die "the focused pane is not inside a Git repository"

# Prevent accidentally reviewing repo A while focused on repo B.
local_slug="$(
  cd "$repo_root"
  gh repo view --json nameWithOwner --jq '.nameWithOwner'
)" || die "could not identify the focused GitHub repository"

normalized_local="$(
  printf '%s' "$local_slug" | tr '[:upper:]' '[:lower:]'
)"
normalized_pr="$(
  printf '%s' "$pr_slug" | tr '[:upper:]' '[:lower:]'
)"

[[ "$normalized_local" == "$normalized_pr" ]] ||
  die "focused repository is $local_slug, but the PR belongs to $pr_slug"

# Use one reusable, isolated worktree per PR.
review_root="${HERDR_PR_REVIEW_ROOT:-$HOME/.cache/herdr/pr-reviews}"
review_dir="$review_root/${owner}-${repository}-pr-${pr_number}"

mkdir -p "$review_root"

if [[ -e "$review_dir" ]]; then
  git -C "$review_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    die "$review_dir exists but is not a Git worktree"

  [[ -z "$(git -C "$review_dir" status --porcelain)" ]] ||
    die "existing review worktree has local changes: $review_dir"
else
  git -C "$repo_root" worktree add --detach "$review_dir" HEAD
  worktree_created=true
fi

# gh handles regular and fork-based PRs. --detach avoids creating or
# conflicting with a local branch.
(
  cd "$review_dir"
  gh pr checkout "$pr_url" --detach
)

pr_title="$(
  cd "$review_dir"
  gh pr view "$pr_url" --json title --jq '.title'
)"

# Create the review pane without taking focus from your current work.
split_json="$(
  "$herdr" pane split "$source_pane" \
    --direction right \
    --ratio 0.5 \
    --cwd "$review_dir" \
    --no-focus
)"

review_pane="$(
  printf '%s' "$split_json" | jq -r '.result.pane.pane_id'
)"

[[ -n "$review_pane" && "$review_pane" != null ]] ||
  die "Herdr did not return the new pane ID"

# Names must be unique among live agents.
agent_name="review-${pr_number}-$(date +%s)"

"$herdr" agent start "$agent_name" \
  --kind cursor \
  --pane "$review_pane" \
  --timeout 60000 \
  -- \
  --mode=ask \
  --model auto

prompt=$(
  cat <<EOF
Review this pull request:

PR: $pr_url
Title: $pr_title
Repository: $pr_slug
Local checkout: $review_dir

The PR head is already checked out in this isolated worktree.

Instructions:
- Remain read-only.
- Do not edit files, commit, push, or post anything to GitHub.
- Read the PR description and existing review discussion with gh.
- Compare the complete PR diff against its merge base.
- Inspect relevant callers, tests, configuration, and nearby code rather
  than reviewing the diff in isolation.
- Follow AGENTS.md, .cursor/rules, .cursor/BUGBOT.md, and established
  repository conventions when present.
- Focus on correctness, regressions, authorization, security, compatibility,
  missing tests, and operational risk.
- Exclude generic style preferences and issues enforced by existing tooling.
- Clearly label uncertain findings instead of presenting them as facts.

Return:
1. Verdict: approve, approve with nits, or request changes.
2. Findings ordered by severity.
3. For every finding: severity, confidence, file:line, impact, evidence,
   and a concrete suggested fix.
4. Missing tests or documentation.
5. Blocking questions for the author.

If there are no actionable findings, say so explicitly.
EOF
)

"$herdr" agent prompt "$agent_name" "$prompt"

# Preserve the worktree after successful launch.
worktree_created=false
review_pane=""
trap - EXIT

printf 'Started %s for PR #%s in %s\n' \
  "$agent_name" "$pr_number" "$review_dir"
