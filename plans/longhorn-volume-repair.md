# Repairing Corrupt Longhorn Volumes

## Status

Active runbook — validated against sonarr-config (2026-11-02) and
prowlarr-config (2026-11-03).

## Goal

Step-by-step recovery for a Longhorn-backed PersistentVolume whose
filesystem refuses to mount after an unclean node shutdown. This is a
manual guideline by design: no automation should mask the root cause. If
corruption keeps happening, use the
[crash investigation](./andromeda-crash-investigation.md) instead.

## Recognizing the failure

A pod stuck in `ContainerCreating` with `FailedMount` events that never
resolve, for example:

```console
$ kubectl -n <namespace> describe pod <pod>
Events:
  Warning  FailedMount  kubelet  MountVolume.MountDevice failed for volume
  "pvc-<id>": rpc error: ... mount failed: exit status 32
  Output: mount: ...: cannot mount; probably corrupted filesystem on
  /dev/longhorn/pvc-<id>.
```

Confirm it is filesystem corruption and not something else:

- On the node, the kernel log shows `XFS (sd?): Corruption detected.
  Unmount and run xfs_repair` and `log mount failed` — the XFS journal
  contains an unreplayable record (typical after a hard freeze).
- Longhorn reports the volume `attached` and `healthy` — the block layer
  is fine, only the guest filesystem is damaged. Do not touch Longhorn
  replicas.
- A `ReadWriteOncePod ... already in-use by another pod` scheduling event
  is different noise: the old pod still holds the claim. Delete the stale
  pod instead.

## Safety first

Before repairing, check the fallback position:

```console
$ kubectl -n longhorn-system get volume pvc-<id> -o jsonpath='{.status.lastBackupAt}'
```

- A recent backup exists (daily 23:00 to the Hetzner storagebox) — worst
  case the PVC can be recreated from it.
- Optionally take a fresh Longhorn snapshot first (Longhorn UI or
  `kubectl -n longhorn-system patch volumes.longhorn.io ...`) so the
  corrupt state is preserved for comparison.

## Repair procedure

`xfs_repair -L` zeroes the unreplayable journal and fixes the metadata it
can. On a config-only PVC (GiB-range) this takes seconds and keeps the
application data.

1. **Do not scale the workload to zero.** Detaching the volume makes the
   `/dev/longhorn/pvc-<id>` device disappear, and Longhorn only reattaches
   it when a pod asks for it. Leave the failing pod running; kubelet
   retries the mount every 2m02s, which keeps the volume attached.

2. **Pick the repair window.** Kubelet backs off 2m02s after each failed
   mount. Run the repair immediately after a fresh `FailedMount` event:

   ```console
   $ kubectl -n <namespace> get events --sort-by=.lastTimestamp | grep FailedMount
   ```

3. **Run the repair from the instance-manager pod**, which is privileged
   and sees the volume devices:

   ```console
   $ kubectl -n longhorn-system get pods -o name | grep instance-manager
   $ kubectl -n longhorn-system exec <instance-manager-pod> -- \
       xfs_repair -L /dev/longhorn/pvc-<id>
   ```

   A successful run ends with `done`. Warnings about inodes claiming free
   blocks or missing reverse-mapping records are normal damage from the
   crash and are fixed during the run.

4. **Restart the pod** to skip the remaining mount backoff:

   ```console
   $ kubectl -n <namespace> delete pod <pod>
   ```

   The replacement pod mounts on its first attempt and should reach
   `Running` within a couple of minutes.

5. **Verify the application** answers its health endpoint (for example
   `wget -qO- http://localhost:<port>/ping` from inside the pod).

## If repair fails or data looks wrong

Restore from the Hetzner backup instead: delete the PVC (the reclaim
policy is `Retain`, so the PV survives) and recreate the workload with a
PVC restored from the Longhorn backup volume (Longhorn UI: Backup >
Restore, or `kubectl apply` a PVC with the `longhorn.io/volume-source`
annotation), then delete the retained PV of the broken volume.

## Root-cause reminder

Every incident of this kind means the node went down uncleanly. Before
assuming bad luck, check the crash cadence:

```console
$ ssh andromeda 'last reboot | head'
```

Regular intervals point at a systemic freeze — see
[andromeda crash investigation](./andromeda-crash-investigation.md).
