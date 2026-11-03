# Andromeda Crash Investigation

## Status

In progress — kdump capture deployed 2026-11-03.

## Goal

Find the root cause of the hard-freeze that has been crashing andromeda
roughly every 6 hours since 2026-09-21, so that the recurring XFS volume
corruption on Longhorn volumes stops at the source instead of being patched
with [volume repairs](./longhorn-volume-repair.md).

## Evidence gathered so far

- Boot history shows a stable month (2026-08-15 to 2026-09-21) followed by
  reboots every ~5h40m-6h05m, night and day, starting 2026-09-21 05:22.
- Journals of every crashed boot end mid-normal-operation: no shutdown
  messages, no kernel panic, no OOM kill, no lockup/watchdog trace, no
  MCE. The journal just stops, and the machine is back ~3-4 minutes later.
- The hardware watchdog (`sp5100-tco`) is present but inactive, so it is
  not the component resetting the machine.
- Same kernel (6.18.38, built 2026-07-04) before and after 2026-09-21, so
  the freeze was not introduced by a kernel version change. The nearest
  config change is the flake lock update of 2026-09-20.
- Each unclean shutdown risks corrupting the XFS journals of mounted
  Longhorn volumes: sonarr-config was hit 2026-11-02, prowlarr-config on
  2026-11-03, and XFS corruption traces appeared on several other volumes
  (`sdu`, `sdy`, `sde`) that recovered via journal replay.

## What has been deployed

In `hosts/andromeda/configuration.nix`:

- `boot.crashDump.enable` — kexec into a dump kernel on panic and arm the
  NMI watchdog. A crash now leaves the machine in rescue with the dump at
  `/proc/vmcore`.
- `kernel.softlockup_panic` / `kernel.hardlockup_panic` — convert CPU hangs
  into capturable panics instead of freezing silently.
- `kernel.panic = 60` — if kdump fails to trigger, reboot after 60 s so the
  NAS recovers by itself.

## Procedure when the next crash happens

The machine boots into rescue and **stays down** until handled — that is
intentional, so the dump is not lost. The crash cadence is ~6 h, so expect
this within hours of the config going live.

1. `ssh andromeda` — the machine sits in the rescue environment.
2. Save the dump before anything else:

   ```console
   $ mkdir -p /var/crash
   $ cp --sparse=always /proc/vmcore /var/crash/vmcore-$(date +%Y%m%d-%H%M)
   $ reboot
   ```

   The dump can be tens of GiB (32 GiB RAM, `--sparse=always` helps); if
   space on the root disk is tight, save it to `/mnt/ssd` or `/mnt/hdd`
   instead.

3. Analyse the dump on any machine with `crash`:

   ```console
   $ nix shell nixpkgs#crash
   $ crash /var/crash/vmcore-<ts> <vmlinux with debug info for 6.18.38>
   ```

   Interesting first commands inside `crash`: `log`, `bt`, `ps`,
   `foreach bt`.

## Interpreting the capture

- **A dump exists** — read the panic backtrace; the usual suspects on this
  host are the proprietary NVIDIA module (the kernel is tainted `P O`),
  a CIFS stall against the Hetzner storagebox, or a zen-kernel bug.
  Whatever shows up in `bt` leads the fix.
- **No dump ever appears and the machine reboots anyway** — the freeze is
  below the kernel (power loss, PSU, board). Check the PSU, run `memtest86+`
  from the boot menu for a few hours, and inspect SMART data
  (`smartctl -a`) and temperatures for the ~6 h pattern.

## After the investigation

- Remove `boot.crashDump` (or keep it; it is cheap at 512 MiB of reserved
  memory) and remove the panic sysctls once the root cause is fixed.
- Keep the [volume repair runbook](./longhorn-volume-repair.md) — it is
  the correct manual response for any future corruption, but it treats
  symptoms, not the cause.
