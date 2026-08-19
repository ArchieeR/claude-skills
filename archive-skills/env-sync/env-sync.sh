#!/usr/bin/env bash
#
# env-sync — compare/sync local .env.local against Vercel env vars.
# Repo-agnostic. Auto-detects monorepo (web app in subdir) vs single-repo.
#
# Usage (run from any repo, or pass --repo path):
#   env-sync diff [--env production|preview]
#   env-sync push <VAR_NAME> [--env production]
#   env-sync push-all-missing [--env production]
#   env-sync pull [--env production]
#
# Layout detection:
#   1. If $PWD/.vercel/project.json exists → single-repo, .env.local is here
#   2. If $PWD/apps/web/.env.local exists and $PWD/.vercel/project.json
#      exists → monorepo (apps/web layout)
#   3. Walk up from CWD to find the closest .vercel/project.json
#
# Safety:
#   - Masks values in `diff` output (first 8 chars only)
#   - Warns if pushing test-shaped key to production
#   - Warns if pulling live-shaped key to local

set -euo pipefail

ENV_TARGET="production"
REPO_HINT=""

# Parse flags
args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV_TARGET="$2"
      shift 2
      ;;
    --repo)
      REPO_HINT="$2"
      shift 2
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done
set -- "${args[@]:-}"

# ── Layout detection ─────────────────────────────────────────────────────

START_DIR="${REPO_HINT:-$PWD}"

# Walk up to find the closest .vercel/project.json
find_vercel_root() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.vercel/project.json" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

VERCEL_ROOT="$(find_vercel_root "$START_DIR" || true)"

if [[ -z "$VERCEL_ROOT" ]]; then
  echo "❌ No .vercel/project.json found in $START_DIR or parents." >&2
  echo "   Run 'vercel link' in this repo first." >&2
  exit 1
fi

# Find .env.local — prefer apps/web/.env.local (monorepo), else root
if [[ -f "$VERCEL_ROOT/apps/web/.env.local" ]]; then
  ENV_DIR="$VERCEL_ROOT/apps/web"
  LAYOUT="monorepo (apps/web)"
elif [[ -f "$VERCEL_ROOT/.env.local" ]]; then
  ENV_DIR="$VERCEL_ROOT"
  LAYOUT="single-repo"
else
  echo "❌ No .env.local found at $VERCEL_ROOT or $VERCEL_ROOT/apps/web/" >&2
  exit 1
fi

LOCAL_ENV="$ENV_DIR/.env.local"
VERCEL_ENV="$ENV_DIR/.env.vercel.${ENV_TARGET}.local"

PROJECT_NAME="$(grep -o '"projectName":"[^"]*"' "$VERCEL_ROOT/.vercel/project.json" | cut -d'"' -f4)"

# ── Helpers ───────────────────────────────────────────────────────────────

pull_vercel() {
  echo "→ Pulling Vercel $ENV_TARGET env for project: $PROJECT_NAME"
  (cd "$VERCEL_ROOT" && npx -y vercel env pull "$VERCEL_ENV" --environment="$ENV_TARGET" --yes) >/dev/null 2>&1
  echo "✓ Saved to $VERCEL_ENV"
}

var_names() {
  grep -E '^[A-Z_][A-Z0-9_]*=' "$1" 2>/dev/null | cut -d= -f1 | sort -u
}

get_value() {
  grep "^${2}=" "$1" 2>/dev/null | head -1 | cut -d= -f2- | sed 's/^"//; s/"$//'
}

mask() {
  local val="$1"
  if [[ ${#val} -le 8 ]]; then
    printf '***'
  else
    printf '%s***' "${val:0:8}"
  fi
}

warn_if_test_in_prod() {
  local val="$1"
  if [[ "$val" =~ ^sk_test_|^pk_test_|^test_|^dev_ ]]; then
    echo "  ⚠️  WARNING: value looks like a TEST key ($(mask "$val")). Pushing to production?" >&2
    read -r -p "  Continue? [y/N] " ans
    [[ "$ans" != "y" && "$ans" != "Y" ]] && return 1
  fi
  return 0
}

# ── Commands ──────────────────────────────────────────────────────────────

cmd="${1:-diff}"

case "$cmd" in
  diff|"")
    pull_vercel
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Project:  $PROJECT_NAME"
    echo "  Layout:   $LAYOUT"
    echo "  Env dir:  $ENV_DIR"
    echo "  Compare:  .env.local ↔ Vercel $ENV_TARGET"
    echo "═══════════════════════════════════════════════════════════"

    local_vars=$(var_names "$LOCAL_ENV")
    vercel_vars=$(var_names "$VERCEL_ENV")
    only_local=$(comm -23 <(echo "$local_vars") <(echo "$vercel_vars"))
    only_vercel=$(comm -13 <(echo "$local_vars") <(echo "$vercel_vars"))
    both=$(comm -12 <(echo "$local_vars") <(echo "$vercel_vars"))

    if [[ -n "$only_local" ]]; then
      echo ""
      echo "🔼 LOCAL ONLY (push to Vercel?):"
      while IFS= read -r v; do [[ -z "$v" ]] && continue; echo "   • $v"; done <<< "$only_local"
    fi

    if [[ -n "$only_vercel" ]]; then
      echo ""
      echo "🔽 VERCEL ONLY (missing locally):"
      while IFS= read -r v; do [[ -z "$v" ]] && continue; echo "   • $v"; done <<< "$only_vercel"
    fi

    if [[ -n "$both" ]]; then
      echo ""
      diffs=0
      encrypted=0
      while IFS= read -r v; do
        [[ -z "$v" ]] && continue
        local_val=$(get_value "$LOCAL_ENV" "$v")
        vercel_val=$(get_value "$VERCEL_ENV" "$v")
        if [[ "$local_val" != "$vercel_val" ]]; then
          # Vercel returns "" for encrypted/sensitive vars on pull — can't compare
          if [[ -z "$vercel_val" ]]; then
            encrypted=$((encrypted + 1))
            continue
          fi
          if [[ $diffs -eq 0 ]]; then
            echo "⚠️  VALUE DIFFERS:"
          fi
          echo "   • $v"
          echo "       local:  $(mask "$local_val")"
          echo "       vercel: $(mask "$vercel_val")"
          diffs=$((diffs + 1))
        fi
      done <<< "$both"
      [[ $diffs -eq 0 ]] && echo "✓ Common vars: no comparable value mismatches."
      if [[ $encrypted -gt 0 ]]; then
        echo "🔒 ${encrypted} encrypted var(s) on Vercel — values not exposed by CLI, can't compare."
        echo "   (To verify, push from local — Vercel will replace whatever's there.)"
      fi
    fi

    echo ""
    echo "Next: env-sync push <VAR>  |  env-sync push-all-missing  |  env-sync pull"
    ;;

  push)
    if [[ -z "${2:-}" ]]; then
      echo "Usage: env-sync push <VAR_NAME>" >&2
      exit 1
    fi
    var="$2"
    val=$(get_value "$LOCAL_ENV" "$var")
    if [[ -z "$val" ]]; then
      echo "❌ $var not found in $LOCAL_ENV" >&2
      exit 1
    fi
    [[ "$ENV_TARGET" == "production" ]] && ! warn_if_test_in_prod "$val" && exit 1
    echo "→ Pushing $var to Vercel $ENV_TARGET ($PROJECT_NAME)..."
    (cd "$VERCEL_ROOT" && npx -y vercel env rm "$var" "$ENV_TARGET" --yes) 2>/dev/null || true
    printf "%s" "$val" | (cd "$VERCEL_ROOT" && npx -y vercel env add "$var" "$ENV_TARGET")
    echo "✓ Pushed $var"
    ;;

  push-all-missing)
    pull_vercel
    local_vars=$(var_names "$LOCAL_ENV")
    vercel_vars=$(var_names "$VERCEL_ENV")
    only_local=$(comm -23 <(echo "$local_vars") <(echo "$vercel_vars"))

    if [[ -z "$only_local" ]]; then
      echo "✓ Nothing to push — all local vars exist on Vercel"
      exit 0
    fi

    echo "Will push to Vercel $ENV_TARGET ($PROJECT_NAME):"
    while IFS= read -r v; do [[ -z "$v" ]] && continue; echo "   • $v"; done <<< "$only_local"
    echo ""
    read -r -p "Continue? [y/N] " ans
    [[ "$ans" != "y" && "$ans" != "Y" ]] && { echo "Aborted."; exit 0; }

    while IFS= read -r v; do
      [[ -z "$v" ]] && continue
      val=$(get_value "$LOCAL_ENV" "$v")
      [[ "$ENV_TARGET" == "production" ]] && ! warn_if_test_in_prod "$val" && continue
      echo "→ $v"
      printf "%s" "$val" | (cd "$VERCEL_ROOT" && npx -y vercel env add "$v" "$ENV_TARGET") >/dev/null
    done <<< "$only_local"
    echo "✓ Done"
    ;;

  pull)
    pull_vercel
    echo ""
    echo "Vercel $ENV_TARGET env saved to: $VERCEL_ENV"
    echo "Compare manually: diff <(sort \"$LOCAL_ENV\") <(sort \"$VERCEL_ENV\")"
    ;;

  pull-missing)
    pull_vercel
    local_vars=$(var_names "$LOCAL_ENV")
    vercel_vars=$(var_names "$VERCEL_ENV")
    only_vercel=$(comm -13 <(echo "$local_vars") <(echo "$vercel_vars"))

    if [[ -z "$only_vercel" ]]; then
      echo "✓ Nothing to pull — $LOCAL_ENV has all Vercel vars"
      exit 0
    fi

    echo "Will append to $LOCAL_ENV (vars only on Vercel $ENV_TARGET):"
    while IFS= read -r v; do [[ -z "$v" ]] && continue; echo "   • $v"; done <<< "$only_vercel"
    echo ""
    echo "⚠️  These are PRODUCTION values. Often you want different (test/dev)"
    echo "    values for local. Review before running your dev server."
    echo ""
    read -r -p "Append anyway? [y/N] " ans
    [[ "$ans" != "y" && "$ans" != "Y" ]] && { echo "Aborted."; exit 0; }

    {
      echo ""
      echo "# ── Pulled from Vercel $ENV_TARGET on $(date +%Y-%m-%d) ──"
      while IFS= read -r v; do
        [[ -z "$v" ]] && continue
        val=$(get_value "$VERCEL_ENV" "$v")
        if [[ "$val" =~ ^sk_live_|^pk_live_ ]]; then
          echo "# ⚠️  LIVE KEY — replace with test value before running dev server"
        fi
        echo "${v}=${val}"
      done <<< "$only_vercel"
    } >> "$LOCAL_ENV"
    echo "✓ Appended to $LOCAL_ENV"
    ;;

  *)
    echo "Unknown command: $cmd" >&2
    echo "Usage: env-sync [diff | push <VAR> | push-all-missing | pull | pull-missing] [--env production|preview]" >&2
    exit 1
    ;;
esac
