---
name: memory
description: RAM + MCP-stacking audit for macOS — find what's eating memory, detect duplicate MCP servers across config layers, find stale Claude Code sessions holding GBs, and check Spotlight indexing churn from node_modules. Use when the user says "RAM is clogged", "memory is full", "check my memory", "what's eating RAM", "my Mac is slow", "/memory", or shows an Activity Monitor screenshot. This is about physical RAM and processes — NOT about memory files, CLAUDE.md, or stored facts.
---

# Memory (RAM) Audit

RAM & MCP-stacking audit runbook for macOS. Diagnose in this order: **too many Claude Code sessions × too many MCP servers × `npx` double-spawn**, then **Spotlight indexing churn from `node_modules`**, then **stale sessions holding GBs**. Don't skip to killing things.

## Why this recurs (the standing diagnosis)

Every Claude Code session spawns **one process per configured MCP server, plus an `npx`/`npm exec` launcher process that does nothing but hold the child**. So each MCP server costs ~2 processes and ~250–300 MB.

MCP config layers **stack** (they do not override each other):

| Layer | Scope |
|---|---|
| `~/.claude.json` → root `mcpServers` | every session, everywhere |
| `~/.claude/settings.json` → `mcpServers` | every session, everywhere |
| `~/.claude.json` → `projects[<cwd>].mcpServers` | that project only |
| `<project>/.mcp.json` → `mcpServers` | that project only |

A server named in two layers is **launched twice**. Common offenders: `gcloud`, `observability`, `shadcn` (name-identical across layers), plus functional duplicates like `firebase` / `firebase-mcp-server` and `firefox-devtools` / `firefox-headed`.

**Math:** 20 configured servers → ~40 processes → ~1.2 GB **per session**. Three sessions open = ~3.6 GB before any real work.

### The boot storm

MCP servers running from source via `npx tsx src/mcp/stdio.ts` chain multiple processes, and `tsx` compiles the whole TypeScript tree **at every session boot**.

Start 5 sessions within ~30s and you get 5 simultaneous compiles: node footprint spikes heavily, free RAM plummets, and macOS grows the swap file. The swap does not shrink back immediately without a reboot, keeping the machine sluggish.

So: measure twice, ~60–90s apart. A terrifying first reading may just be a boot spike. Check session age (`etime`) before taking drastic steps.

**Fixes:** pre-build MCP servers to JavaScript and run via plain `node dist/index.js`; stagger session starts; don't open 5 at once.

## Step 1 — Measure

```bash
echo "=== MEMORY ==="; sysctl -n hw.memsize | awk '{print $1/1073741824" GB total"}'
memory_pressure 2>/dev/null | tail -3; sysctl vm.swapusage
vm_stat | awk '/Pages free/{f=$3} /Pages active/{a=$3} /Pages inactive/{i=$3} /Pages wired/{w=$4} /occupied by compressor/{c=$5} END {gsub(/\./,"",f);gsub(/\./,"",a);gsub(/\./,"",i);gsub(/\./,"",w);gsub(/\./,"",c); printf "free %.1fGB | active %.1fGB | inactive %.1fGB | wired %.1fGB | compressor %.1fGB\n", f*16384/1e9,a*16384/1e9,i*16384/1e9,w*16384/1e9,c*16384/1e9}'

echo; echo "=== NODE/NPM/CLAUDE FOOTPRINT ==="
ps -Ao rss,command | awk '/node|npm|claude/ {s+=$1; n++} END {printf "%.2f GB across %d processes\n", s/1048576, n}'
ps -Ao rss,command | grep -E 'npm exec|npx' | grep -v grep | awk '{s+=$1} END {printf "  of which npx launcher overhead: %.0f MB across %d procs\n", s/1024, NR}'

echo; echo "=== CLAUDE CODE SESSIONS ==="
ps -Ao pid,etime,command | grep 'claude-code/[0-9].*MacOS/claude --output-format' | grep -v grep | awk '{print "  pid "$1"  age "$2}'
```

Read it as: **>3 GB node / >2 sessions / swap climbing = clogged.** Compressor over ~4 GB means macOS is already fighting. Trust `ps` RSS over Activity Monitor's "Memory" column (which includes compressed + shared pages).

## Step 2 — Find duplicate MCP servers

```bash
python3 - <<'PYEOF'
import json, collections, os
home=os.path.expanduser('~'); cwd=os.getcwd()
cfg=json.load(open(f'{home}/.claude.json')) if os.path.exists(f'{home}/.claude.json') else {}
try: st=json.load(open(f'{home}/.claude/settings.json'))
except Exception: st={}
layers={'~/.claude.json (GLOBAL)':cfg.get('mcpServers',{}),
        '~/.claude/settings.json (GLOBAL)':st.get('mcpServers',{})}
for p,v in cfg.get('projects',{}).items():
    try: in_project=os.path.commonpath((cwd,os.path.abspath(p))) == os.path.abspath(p)
    except ValueError: in_project=False
    if v.get('mcpServers') and in_project: layers[f'~/.claude.json project: {p}']=v['mcpServers']
project_cfg=os.path.join(cwd,'.mcp.json')
if os.path.isfile(project_cfg):
    try: layers['./.mcp.json (PROJECT)']=json.load(open(project_cfg)).get('mcpServers',{})
    except Exception: pass
where=collections.defaultdict(list)
targets=collections.defaultdict(list)
for L,s in layers.items():
    for n,spec in s.items():
        where[n].append(L)
        if isinstance(spec,dict) and spec.get('command'):
            target=json.dumps([spec.get('command'),spec.get('args',[])],sort_keys=True)
            targets[target].append((n,L))
print(f"TOTAL configured here: {sum(len(s) for s in layers.values())}  (~2 procs + ~280MB each)\n")
dupes={n:v for n,v in where.items() if len(v)>1}
print("SAME NAME IN >1 LAYER (spawned twice):" if dupes else "No cross-layer duplicates.")
for n,v in sorted(dupes.items()): print(f"  {n}\n      "+"\n      ".join(v))
aliases={k:v for k,v in targets.items() if len(v)>1 and len({n for n,_ in v})>1}
if aliases:
    print("\nSAME COMMAND + ARGS UNDER DIFFERENT NAMES:")
    for v in aliases.values(): print("  "+"; ".join(f"{n} ({L})" for n,L in v))
PYEOF
```

Run Step 2 from your project root. It compares `mcpServers` across global and matching project scopes in `~/.claude.json`, `~/.claude/settings.json`, and `./.mcp.json`.

## Step 3 — Spotlight churn

`mds_stores` pegged near 100% CPU means Spotlight is crawling `node_modules` or build output across repositories or worktrees.

```bash
n=0
while IFS= read -r d; do touch "$d/.metadata_never_index" 2>/dev/null && n=$((n+1)); done \
  < <(find . -maxdepth 3 \( -name node_modules -o -name .next -o -name .turbo -o -name dist -o -name .firebase \) -type d -prune 2>/dev/null)
echo "marked $n dirs"; ps -o %cpu=,rss= -p "$(pgrep -x mds_stores | head -1)" 2>/dev/null
```

Markers sit in gitignored directories. CPU drops within a minute or two. Undo: `find . -name .metadata_never_index -delete`.

## Step 4 — Kill stale sessions (ASK FIRST)

Killing a session destroys its conversation context. **Always confirm before killing**, and check session age first. Never kill your current active session.

```bash
SELF="${SELF:?Set SELF to the verified current-session PID}"
TARGET_ROOT_PIDS="${TARGET_ROOT_PIDS:?Set TARGET_ROOT_PIDS to the space-separated target root PIDs}"
case "$SELF" in (*[!0-9]*|'') echo "SELF must be a PID" >&2; exit 1;; esac
T=$(mktemp -d)
printf "%s\n" "$TARGET_ROOT_PIDS" | tr ' ' '\n' | grep -E '^[0-9]+$' > "$T/pids.txt"
for i in 1 2 3 4 5 6; do
  ps -Ao pid,ppid | tail -n +2 | awk 'NR==FNR{w[$1];next} ($2 in w){print $1}' "$T/pids.txt" - >> "$T/pids.txt"
  sort -u -o "$T/pids.txt" "$T/pids.txt"
done
grep -vxE "1|$SELF" "$T/pids.txt" | grep -E '^[0-9]+$' > "$T/kill.txt"
echo "targets: $(wc -l < "$T/kill.txt")"; ps -o rss= -p "$(paste -sd, "$T/kill.txt")" | awk '{s+=$1} END {printf "holding %.0f MB\n", s/1024}'
# SAFETY: verify none belong to the current session before firing
xargs kill -TERM < "$T/kill.txt" 2>/dev/null; sleep 4
ps -Ao pid | tail -n +2 | tr -d ' ' | sort > "$T/now.txt"
comm -12 "$T/kill.txt" "$T/now.txt" | xargs kill -KILL 2>/dev/null
```

### ⚠️ zsh word-splitting gotcha

**`kill -TERM $PIDS` silently fails in zsh.** zsh does not word-split unquoted variables, so the whole list is passed as one single argument. Use `xargs kill` or `${=PIDS}`. Always verify kills landed.

## Step 5 — Recommendations

Provide a clear before/after table, then offer structural fixes:

1. **Dedupe config layers** — remove cross-layer repeats; collapse functional duplicates.
2. **Drop `npx -y` / `@latest`** — pin to a resolved binary or pre-built JS script. Halves process count and removes network fetches on session boot.
3. **Scope niche MCPs to projects** — move dev-only or tool-specific MCPs out of global `~/.claude/settings.json` into `./.mcp.json`.
4. **Move secrets from args to env** — pass API keys in `env` blocks rather than CLI `args` (which are world-readable via `ps`).
