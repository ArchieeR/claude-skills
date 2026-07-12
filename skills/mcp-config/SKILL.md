---
name: mcp-config
description: >
  Add, configure, and troubleshoot MCP servers for Claude Code — remote (HTTP/SSE)
  and local (stdio), with auth headers/tokens, user/project/local scopes, and a
  diagnostics playbook for "the server won't connect / won't show up". Use whenever
  setting up a new MCP connector (Intercom, Attio, Apollo, Gojiberry, Stripe, custom
  APIs…), wiring a token-authed remote server, or debugging an MCP that isn't loading.
user-invokable: true
argument-hint: "[add <name> | debug <name> | list]"
---

# mcp-config — Claude Code MCP setup & debugging

## ⭐ The golden rule (this is what bites every time)
**Use `claude mcp add` — do NOT hand-edit `~/.claude/settings.json` `mcpServers`.**

Claude Code's connector registry lives in **`~/.claude.json`** (user config), which is what `claude mcp add` writes to and what the `/mcp` refresh reads. Servers hand-added to `~/.claude/settings.json` `mcpServers` may not register / won't show on a soft refresh. (Learned the hard way wiring Intercom — token + endpoint + config were all perfect; it just wasn't in the registry Claude reads.)

If a server already loads fine from `settings.json`, leave it — but for anything NEW, use the CLI.

## Scopes
`-s local` (this project only, default) · `-s user` (all your projects — use for personal connectors like Intercom/Attio) · `-s project` (committed `.mcp.json`, shared with the team).

## Adding servers

**Remote HTTP server with a bearer token** (preferred for hosted MCPs — native, no `mcp-remote` needed):
```bash
claude mcp add --transport http --scope user <name> "https://host/mcp" \
  --header "Authorization: Bearer <TOKEN>"
```

**Remote SSE server** (legacy): `--transport sse` instead of `http`.

**Local stdio server** (a command):
```bash
claude mcp add --scope user <name> -- <command> <args...>
# e.g. claude mcp add -s user foo -- npx -y some-mcp-package
```

**OAuth remote (no token)** — add without a header; first connect opens a browser:
```bash
claude mcp add --transport http --scope user <name> "https://host/mcp"
```

**`mcp-remote` bridge** — only if a client lacks native remote support:
```bash
claude mcp add -s user <name> -- npx -y mcp-remote "https://host/mcp" \
  --header "Authorization:Bearer <TOKEN>"
```
Note the header form has **no space** after the colon in the mcp-remote `--header` arg (`Authorization:Bearer …`), unlike the native `claude mcp add --header "Authorization: Bearer …"`.

## Diagnostics playbook (server won't connect / won't show)

1. **Is it registered + connected?**
   ```bash
   claude mcp list            # all servers + ✔ Connected / ! Needs auth / ✗ failed
   claude mcp get <name>      # scope, transport, url, headers, status
   ```
2. **Does the remote endpoint accept the token?** (isolates auth from Claude/config) — a 200 here means token+endpoint are fine; the problem is registration:
   ```bash
   curl -s -X POST "https://host/mcp" \
     -H "Authorization: Bearer <TOKEN>" -H "Content-Type: application/json" \
     -H "Accept: application/json, text/event-stream" \
     -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"diag","version":"1.0"}}}' \
     -w "\n[HTTP %{http_code}]\n"
   ```
   Healthy reply contains `"serverInfo":{"name":...}` and `[HTTP 200]`.
3. **If using `mcp-remote`, test it directly** (look for `Proxy established successfully`):
   ```bash
   npx -y mcp-remote "https://host/mcp" --header "Authorization:Bearer <TOKEN>"
   # Ctrl-C after you see "Connected to remote server" / "Proxy established"
   ```
4. **Clear stale mcp-remote state** (fixes ghosts after failed attempts):
   ```bash
   pkill -f mcp-remote ; rm -rf ~/.mcp-auth
   ```

## Gotchas (why it "won't show up")
- **Other sessions open / soft refresh:** new servers load on session **start**. Already-running sessions (and sometimes `/mcp` soft refresh) won't see a just-added server — open a **fresh terminal/session**, or it'll appear after `claude mcp add` since that writes the registry. You don't need to quit the other sessions.
- **`settings.json` ≠ registry:** see the golden rule. `~/.claude.json` is the source of truth for `claude mcp add` servers.
- **`${VAR}` indirection in args isn't expanded** by Claude Code's launcher — inline the literal value instead of `Authorization:${AUTH_HEADER}`.
- **Region-gated servers:** some hosted MCPs are region-locked (e.g. **Intercom MCP = US workspaces only**). Confirm workspace region first (the API base / `GET /me`).
- **Node:** `mcp-remote` needs Node ≥18 (`node --version`).
- **First-run download:** `npx -y <pkg>` downloads on first launch; usually cached after one run (`ls ~/.npm/_npx/*/node_modules/<pkg>`).

## Security
A token in `--header` is stored in `~/.claude.json` in plaintext. Fine for a personal machine; **rotate it** if it leaks (e.g. pasted in chat). Prefer OAuth (no stored secret) when the server supports it. Remove a server with `claude mcp remove "<name>" -s <scope>`.

## Quick reference — what's NOT in an MCP
MCPs expose a fixed tool set; some API surface is always REST-only. Example: the **Intercom MCP** covers conversations/contacts/companies/Help-Center-articles but **not** the AI Content / External Pages endpoints — those need the REST API + token. Always check whether the task needs an endpoint the MCP doesn't expose before assuming the MCP is enough.
