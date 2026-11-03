# Stalwart 1.0 Migration On Aether

## Status

Planning and research complete; implementation not started. This plan migrates
the production mail server on `aether` from Stalwart v0.16 to Stalwart v1.0
using upstream's `stalwart-migrate` copy-based migration.

## Goal

Replace the running Stalwart 0.16 deployment with Stalwart 1.0 with a single
short maintenance window, preserving all accounts, mail, calendars, contacts,
identities, spam training data, the outbound queue, and scheduled tasks. The
0.16 data store is never modified and remains the rollback fallback until the
1.0 deployment has proved itself.

## Decisions

- Migrate with upstream `stalwart-migrate` in a single-window final run. The
  store is only ~313 MB, so incremental runs are unnecessary.
- Package `stalwart-migrate` as a custom Nix package under `pkgs/`, pinned to
  **v1.0.5** (see [Tool/server version pairing](#tool-and-server-version-pairing)).
- Replace the existing `stalwart.service` unit contents in place, keeping the
  unit name so ACME `reloadServices` and muscle memory stay unchanged.
- New layout: user/group `stalwart-1`, state under `/var/lib/stalwart-1`,
  RocksDB database at `/var/lib/stalwart-1/db`. The old `stalwart-16`
  user and `/var/lib/stalwart-16` stay untouched until Phase 4.
- Keep the declarative settings pattern: recovery-mode preStart applies an
  NDJSON plan with `stalwart-cli apply` on every start. All environment
  variables the pattern depends on still exist in 1.0
  (`STALWART_RECOVERY_MODE`, `STALWART_RECOVERY_MODE_PORT`,
  `STALWART_RECOVERY_ADMIN`, `STALWART_PUBLIC_URL`, `STALWART_HOSTNAME`).
- Keep ACME-managed TLS via NixOS `security.acme`; Stalwart continues to load
  the certificate files from `/var/lib/acme/mail.mgrlab.dk`.

## Current State (verified)

- `hosts/aether/mailserver.nix` runs `pkgs.stalwart_0_16` with a manual
  `stalwart.service` because the nixpkgs `services.stalwart` module still
  targets v0.15 (TOML settings). This remains true for 1.0; the custom
  service stays.
- **The running server is 0.16.23**, but the flake evaluates
  `stalwart_0_16` to **0.16.27** — aether is a generation behind the current
  config. `stalwart-migrate` requires the source to be exactly 0.16.27, so the
  current config must be deployed before the migration.
- Locked nixpkgs provides `stalwart_1_0` 1.0.0 with `passthru.webui`
  (webui 2.0.0) and `passthru.spam-filter` (spam-filter 3.0.3), and
  `stalwart-cli` 1.0.14 (already running in production against the 0.16
  server, so the CLI/server pairing across the migration boundary is proven).
- Data store: RocksDB with blobs inside the database (no external blob store),
  ~313 MB total under `/var/lib/stalwart-16`. Root filesystem has ~20 GB free.
- Settings are managed as an NDJSON plan applied by
  `stalwart-cli apply` against a temporary recovery-mode listener on
  `127.0.0.1:18080` during `preStart` (port stays closed in the firewall).
  The plan currently contains: Domain (`mgrlab.dk`, manual DNS/cert
  management), file-backed Certificate, SystemSettings, five
  NetworkListeners, `Http.useXForwarded`, a Journal Tracer, the WebUI
  Application, spam filter rules URL, and an MTA connection strategy pinning
  the outbound source IP `138.199.154.23`.
- The WebUI is reached through Pangolin's Traefik over the `podman1` bridge on
  port 4848; the firewall only exposes 4848 on that interface. Mail protocols
  (25, 465, 587, 993) terminate directly at Stalwart.
- The admin password comes from the `STALWART_ADMIN_PASSWORD` SOPS secret via
  `LoadCredential` and is used through the recovery-admin mechanism.
- `stalwart-migrate` is **not** in nixpkgs and must be packaged locally.

## Tool And Server Version Pairing

Two constraints discovered during research are easy to get wrong:

1. **Edition match.** nixpkgs builds `stalwart_1_0` with
   `buildNoDefaultFeatures = true` and **no `enterprise` feature** (see
   `pkgs/by-name/st/stalwart_1_0/package.nix`). Upstream states that a server
   compiled from source without the `enterprise` feature requires the
   **`-oss` build of `stalwart-migrate`**. The local package must therefore
   also be built without the enterprise feature.
2. **Store format match.** The tool writes stores "for Stalwart v1.0.2" as of
   tool release v1.0.6 (2026-11-03). The nixpkgs server is **1.0.0**. A 1.0.0
   server must not be pointed at a 1.0.2-format store, so the tool is pinned to
   **v1.0.5**, which writes 1.0.0/1.0.1-format stores (v1.0.1 changed no
   stored schema). Before executing the migration, re-check
   `nix eval .#nixosConfigurations.aether.pkgs.stalwart_1_0.version`: if
   nixpkgs has bumped the server to >= 1.0.2, bump the tool pin to >= 1.0.6
   and re-read that release's changelog.

Trade-offs of pinning to v1.0.5 instead of v1.0.6:

- The v1.0.6 encryption-at-rest conversion does not apply: no accounts have
  public keys, so no encrypted data exists. No impact.
- The v1.0.6 fix that seeds missing v1 permissions into default roles
  (e.g. `scimAccess` on System Administrator) is missing. If the migrated
  admin role lacks a new permission, grant it in the WebUI after the
  migration. Cosmetic at worst.

## What Changes Between 0.16 And 1.0 (for this deployment)

Settings are JMAP objects in both versions, but 1.0 renumbers every id space
and renames several fields. Raw copies are unsafe; everything goes through
name-based conversion (the migration tool for the store, hand-updating for the
declarative plan). From upstream's `SCHEMA_CHANGES.md`, the fields used by the
current `mailserver.nix` plan:

| 0.16 plan entry | 1.0 replacement |
|---|---|
| `NetworkListener.tlsImplicit` | `implicitTls` |
| `Http.useXForwarded = true` | `Http.clientIpSource = "xForwardedFor"` plus `Http.forwardedHops = 1` (Traefik is a single proxy hop). Keep the 4848 listener reachable only via the `podman1` interface: with `clientIpSource != "peer"` any client that bypasses the proxy could spoof its address. The existing firewall rule already enforces this. |
| `MtaConnectionStrategy.sourceIps."0".sourceIp` | `localIps."0".localIp` |
| `Application.enabled` | `enable` |
| `Application.resourceUrl` | same field, but webui 2.0.0 from `${pkgs.stalwart_1_0.webui}/webui.zip`; 1.0 serves only WebUI v2 |
| `SpamSettings.spamFilterRulesUrl` | field name unchanged; spam-filter 3.0.3 from `${pkgs.stalwart_1_0.spam-filter}` |
| Domain, Certificate, SystemSettings, Tracer Journal | unchanged; confirm against the conversion report |

Behaviour changes visible to users after the switch:

- OAuth tokens issued by 0.16 are not migrated: everyone signs in to the
  WebUI again.
- IMAP UIDs, UIDVALIDITY, account/document/thread ids and change history are
  preserved. Thunderbird does **not** re-download mailboxes.
- CalDAV/CardDAV/WebDAV clients fetch their data once more (entity tags
  change); sync tokens stay valid. The Thunderbird calendar/address book
  modules on meridian/zenith are affected once, then settle.
- The full-text search index is rebuilt after 1.0 starts; search results are
  incomplete until it finishes.
- Messages gain the `$hasattachment`/`$hasnoattachment` keywords (read-only
  for clients).
- 1.0's `--config` flow, `CONFIG_PATH`, and the recovery-mode environment
  variables are all unchanged from 0.16, so the preStart pattern ports over
  as-is.

## Phase 0 — Pre-Flight (no downtime)

1. Deploy the current config to `aether` (`dply .#aether` or on-host
   `sudo nixos-rebuild switch --flake .#aether`) so the running server is
   **0.16.27**. Verify `stalwart --version` on the host, check
   `journalctl -u stalwart` for a clean preStart `apply`, and confirm mail
   flows (send/receive test).
2. Cold backup: stop the service, copy the store, start it again.

   ```bash
   ssh aether
   sudo systemctl stop stalwart
   sudo cp -a /var/lib/stalwart-16 /var/lib/stalwart-16-backup
   sudo systemctl start stalwart
   ```

3. Re-verify the version pairing from
   [Tool and server version pairing](#tool-and-server-version-pairing)
   against the current flake lock, and confirm the disk still has room for a
   second ~313 MB copy.

## Phase 1 — Nix Implementation (branch or worktree, not deployed)

4. **Package `stalwart-migrate`** in `pkgs/stalwart-migrate/default.nix`,
   registered in `pkgs/default.nix`:
   - `rustPlatform.buildRustPackage` from `fetchFromGitHub` tag `v1.0.5`.
   - Build **without** the enterprise feature (`buildNoDefaultFeatures` /
     feature list without `enterprise`), mirroring the OSS server build.
   - Build inputs follow the nixpkgs stalwart package stack since the tool
     builds against Stalwart's store crates: `bindgenHook`, `protobuf`,
     `pkg-config`, `rocksdb` (set `ROCKSDB_INCLUDE_DIR`/`ROCKSDB_LIB_DIR`),
     `zstd` (`ZSTD_SYS_USE_PKG_CONFIG`), `openssl`, `bzip2`, `sqlite`.
   - The workspace patches `hickory-*` and `librocksdb-sys` to git forks via
     `[patch.crates-io]`; the pinned `Cargo.lock` resolves them, and
     `cargo vendor` (used by the cargo deps fetch) vendors patched git
     dependencies. Iterate on `cargoHash` until the build closes.
   - Confirm the `mapping/` schema snapshots are embedded at build time
     (they are part of the repo checkout) and not needed at runtime.
   - Standard `meta` with `mainProgram = "stalwart-migrate"`, AGPL license,
     platform `linux`.
5. **Rework `hosts/aether/mailserver.nix`** for 1.0:
   - `package = pkgs.stalwart_1_0`, `dataDir = "/var/lib/stalwart-1"`,
     `user = group = "stalwart-1"`, `StateDirectory = "stalwart-1"`,
     config path `/var/lib/stalwart-1/config.json`, RocksDB path
     `/var/lib/stalwart-1/db`. The generated config JSON stays
     `{ "@type" = "RocksDb"; path = ...; }` — byte-compatible with the
     target config the migration tool will have used.
   - Apply the plan-entry renames from the table above. Everything else
     (listeners, ports, ACME wiring with `group = "stalwart-1"`, firewall,
     recovery-mode preStart with `STALWART_RECOVERY_MODE_PORT=18080`,
     `XDG_CACHE_HOME` for the CLI schema cache, SOPS credential, sandbox
     hardening) carries over unchanged.
   - `environment.systemPackages` keeps `package` and `pkgs.stalwart-cli`
     (1.0.14 is now version-matched with the server).
   - Add `pkgs.stalwart-migrate` to the host packages (or the dev shell) so
     the tool is present on aether for the window and for any later
     `rollback`.
6. **Validate the converted plan offline** (optional but recommended):
   check out `stalwart-migrate` v1.0.5, run
   `python3 cli-plan/convert_plan.py prepare|convert` on a snapshot of the
   deployed `/var/lib/stalwart-16/settings.ndjson`, and diff the output
   against the hand-converted Nix plan to catch any missed rename.
7. Format with `nixfmt`, stage everything
   (`git add -A` — flakes ignore unstaged files), then
   `nixos-rebuild dry-build --flake .#aether`.

## Phase 2 — Migration Window

Estimated downtime: minutes (one copy of ~313 MB plus finalisation).

8. **Prepare** (interactive, needs a real TTY, runs as root on aether since
   the store is `0700` owned by `stalwart-16`):

   ```bash
   sudo stalwart-migrate prepare \
     --source /var/lib/stalwart-16/config.json \
     --state /var/lib/stalwart-migrate
   ```

   Expected questions and answers for this deployment:
   - Data categories: keep all defaults (queue, tasks and spam model are
     copied by the final run only).
   - External blob store reuse: moot — blobs live inside the RocksDB store
     and are always copied.
   - Client address behind a reverse proxy (asked because
     `useXForwarded` is set): header `xForwardedFor`, one trusted proxy
     hop.
   - Changed defaults: follow the per-setting recommendation.
   Then review `/var/lib/stalwart-migrate/prepare-report.txt` for dropped
   objects and warnings.

9. **Create the empty target store and config** (root-owned files would make
   the 1.0 service fail to open its store; the tool's `--owner` also chowns
   what it writes, but create the directory with the right owner up front):

   ```bash
   sudo install -d -o stalwart-1 -g stalwart-1 -m 0700 /var/lib/stalwart-1
   sudo install -o stalwart-1 -g stalwart-1 -m 0600 /dev/null /var/lib/stalwart-1/config.json
   cat <<'EOF' | sudo tee /var/lib/stalwart-1/config.json >/dev/null
   { "@type": "RocksDb", "path": "/var/lib/stalwart-1/db" }
   EOF
   ```

   The tool fingerprints source and target configs and refuses a later run
   with different definitions, so this file must keep the same content
   through the final run. The 1.0 service's preStart writes the
   Nix-generated config to the same path with identical content.

10. **Stop 0.16 and run the single final copy:**

    ```bash
    sudo systemctl stop stalwart
    sudo stalwart-migrate run --final \
      --source /var/lib/stalwart-16/config.json \
      --target /var/lib/stalwart-1/config.json \
      --state /var/lib/stalwart-migrate \
      --owner "$(id -u stalwart-1):$(id -g stalwart-1)"
    ```

    The command asks to confirm 0.16 is stopped and watches the source store
    for 30 seconds before copying. It then copies everything including the
    final-run categories, recalculates quotas, queues every object for search
    indexing, verifies a sample of accounts, and writes
    `final-report.txt`.

11. **Review the report** before starting 1.0:

    ```bash
    sudo stalwart-migrate report --state /var/lib/stalwart-migrate --severity error
    ```

    Error rows block finalisation; `--allow-errors` only if the remaining
    errors are understood and acceptable. With time to spare, run
    `stalwart-migrate verify --full` for a full comparison.

12. **Deploy the 1.0 config** (`dply .#aether`, or on-host
    `sudo nixos-rebuild switch --flake .#aether`). The new preStart boots the
    recovery listener on 18080, re-applies the converted plan idempotently
    over the migrated settings, and the main process starts 1.0 on
    `/var/lib/stalwart-1`. Watch the journal for the version banner, plan
    apply, and listener binds.

## Phase 3 — Verification And Rollback Safety

13. Functional checks, in order:
    - `stalwart --version` reports 1.0.x; unit is `active`.
    - Listeners bound on 25/465/587/993 (e.g. `ss -tlnp | grep stalwart`).
    - Thunderbird IMAP reconnects without re-downloading (UIDs preserved).
    - SMTP send + inbound receive test message; check SPF/DKIM/DMARC still
      pass on the receiving side.
    - Admin UI at `https://mail.mgrlab.dk/admin` through Pangolin: sign in
      again (OAuth tokens were dropped), using the same
      `STALWART_ADMIN_PASSWORD` SOPS secret via recovery-admin.
    - Spam filter rules loaded (the converted `DISPOSABLE_REPLY_TO` and new
      `AI_*` tags appear in the report; stock tags are added by the final
      run).
    - Outbound queue drained normally (handed over by the final run).
    - Journal tracer still logging at info.
    - Expect searches to return incomplete results until the index rebuild
      finishes; CalDAV/CardDAV clients refetch once.
14. **Do not delete anything yet.** Keep:
    - `/var/lib/stalwart-16` (untouched source, pristine fallback),
    - `/var/lib/stalwart-16-backup` (cold copy),
    - `/var/lib/stalwart-migrate` (state directory; `rollback` needs it).
15. Rollback paths:
    - **Before 1.0 has served users:** no tool needed — the 0.16 store was
      never modified. Deploy the previous generation and start the old
      service on `/var/lib/stalwart-16`.
    - **After 1.0 has served users:** `stalwart-migrate rollback` copies the
      1.0 store into a *new, empty* 0.16 store, restoring original settings
      via `--forward-state /var/lib/stalwart-migrate`:

      ```bash
      sudo systemctl stop stalwart
      sudo stalwart-migrate rollback \
        --source /var/lib/stalwart-1/config.json \
        --target /var/lib/stalwart-rollback/config.json \
        --state /var/lib/stalwart-rollback \
        --forward-state /var/lib/stalwart-migrate \
        --owner "$(id -u stalwart-16):$(id -g stalwart-16)"
      ```

      Then point the 0.16 service at the rollback store. Mail received while
      1.0 ran comes along; mail clients see no UID resets here either.

## Phase 4 — Cleanup (after a confidence period)

16. Remove the 0.16 artifacts: `stalwart-16` user/group,
    `/var/lib/stalwart-16`, `/var/lib/stalwart-16-backup`, and the
    `stalwart-migrate` package from `environment.systemPackages` if it is no
    longer wanted on the host (keep it available somewhere while the state
    directory exists, for rollback).
17. Update documentation:
    - The "Aether mail server" section in `README.md` (paths, versions, plan
      schema, WebUI v2).
    - Self-review `AGENTS.md` for new conventions worth recording — notably
      the tool/server version-pairing rule (OSS build of the tool for the
      OSS build of the server; tool release must match the server's store
      format) and the `stalwart-migrate` pin rationale.
18. Optionally drop `/var/lib/stalwart-migrate` and
    `/var/lib/stalwart-rollback` once 0.16 is fully retired.

## Risks And Watch Items

- **Sharpest edge: store-format pairing.** Tool v1.0.6+ writes 1.0.2 stores
  the 1.0.0 server may refuse. Re-verify both versions immediately before
  the window; bump the tool pin only together with a server bump.
- **0.16.27 prerequisite.** The window fails before it starts if the running
  server is still 0.16.23; `prepare` refuses other releases. Phase 0 step 1
  is mandatory.
- **`--owner` correctness.** A store left owned by root makes the 1.0
  service fail to open it. Both the manual directory creation and the final
  run must set `stalwart-1` ownership.
- **Default-role permissions.** Tool v1.0.5 predates the fix that seeds new
  v1 permissions into default roles; check the admin role afterwards and
  grant anything missing via the WebUI.
- **Mass-removal guard.** If the tool reports held removals ("the source
  lists fewer accounts than the state database"), stop and investigate —
  that symptom means the source config points at the wrong store. Never
  paper over it with `--allow-mass-removal` without understanding why.
- **Recovery port exposure.** Recovery mode binds all interfaces on
  18080; it must stay closed in the firewall (it already is).
- **Timing.** Upstream is releasing quickly around 1.0 (tool v1.0.6 shipped
  2026-11-03). Re-read the `stalwart-migrate` changelog for anything newer
  than v1.0.5 that affects this plan before executing.

## References

- Migration overview: https://stalw.art/docs/migration/upgrade-0-16/
- Quick guide (all steps with commands): https://stalw.art/docs/migration/upgrade-0-16/quick-guide/
- `prepare` questions and data categories: https://stalw.art/docs/migration/upgrade-0-16/prepare/
- CLI plan conversion: https://stalw.art/docs/migration/upgrade-0-16/cli-plans/
- Schema differences v0.16.27 → v1.0.2: https://github.com/stalwartlabs/stalwart-migrate/blob/main/SCHEMA_CHANGES.md
- Tool repo and changelog: https://github.com/stalwartlabs/stalwart-migrate
- Environment variables in 1.0: https://stalw.art/docs/configuration/environment-variables/
- Reverse proxy and `clientIpSource`: https://stalw.art/docs/server/reverse-proxy/
- v1.0 release notes: https://stalw.art/blog/stalwart-1-0
