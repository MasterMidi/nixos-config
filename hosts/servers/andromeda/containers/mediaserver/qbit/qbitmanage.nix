{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.compose.mediaserver = {
    containers = rec {
      qbitmanage = {
        image = "ghcr.io/hotio/qbitmanage:nightly";
        autoUpdate = "registry";
        networking.networks = ["default" "qbit-public"];
        environment = {
          PGID = builtins.toString config.users.groups.users.gid;
          PUID = builtins.toString config.users.users.michael.uid;
          TZ = config.time.timeZone;
          UMASK = "002";

          QBT_SCHEDULE = "30";
        };
        volumes = [
          "/mnt/ssd/services/qbitmanage/config:/config:rw"
          "${config.sops.templates.QBITMANAGE_CONFIG.path}:/config/config.yml:rw"
          "/mnt/hdd/torrents:/storage/torrents:rw"
        ];
        dependsOn = ["qbit"];
      };
    };
  };

  sops.templates.QBITMANAGE_CONFIG = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      mode = "0600";
      restartUnits = [config.virtualisation.oci-containers.compose.mediaserver.containers.qbitmanage.unitName];
      content = lib.generators.toYAML {} rec {
        commands = {
          dry_run = false;
          cross_seed = false;
          recheck = false;
          cat_update = false;
          tag_update = true;
          rem_unregistered = true;
          tag_tracker_error = true;
          rem_orphaned = true;
          tag_nohardlinks = true;
          share_limits = true;
          skip_qb_version_check = false;
          skip_cleanup = false;
        };

        qbt = {
          host = "${builtins.head config.virtualisation.oci-containers.compose.mediaserver.containers.qbit.networking.aliases}:${toString config.virtualisation.oci-containers.compose.mediaserver.containers.qbit.networking.ports.webui.internal}";
          user = "admin";
          pass = config.sops.placeholder.QBIT_PUBLIC_PASSWORD;
        };

        settings = {
          force_auto_tmm = true;
          force_auto_tmm_ignore_tags = [
            "cross-seed"
          ];
          nohardlinks_tag = "noHL";
          share_limits_tag = "sl";
          tracker_error_tag = "issue";
          share_limits_min_seeding_time_tag = "MinSeedTimeNotReached";
          share_limits_min_num_seeds_tag = "MinSeedsNotMet";
          share_limits_last_active_tag = "LastActiveLimitNotReached";
          cross_seed_tag = "cross-seed";
          cat_filter_completed = true;
          share_limits_filter_completed = true;
          tag_nohardlinks_filter_completed = true;
          cat_update_all = true;
        };

        directory = rec {
          root_dir = "/storage/torrents/public";
          remote_dir = root_dir;
          cross_seed = "${root_dir}/cross-seeds/";
          recycle_bin = "${root_dir}/.Trash-1000";
          torrents_dir = "${root_dir}/.torrents";
          orphaned_dir = "${root_dir}/orphaned_data";
        };

        cat = {
          prowlarr = "${directory.root_dir}/prowlarr";
          radarr = "${directory.root_dir}/radarr";
          sonarr = "${directory.root_dir}/sonarr";
          buffer = "${directory.root_dir}/buffer";
          cross-seed = "${directory.root_dir}/cross-seeds";
        };

        tracker = {
          "cow.milkie.cc" = {
            tag = "milkie";
          };
          "digitalcore.club" = {
            tag = "digitalcore";
          };
        };

        nohardlinks = [
          {
            radarr = null;
          }
        ];

        share_limits = {
          keep = {
            priority = 1;
            include_any_tags = [
              "keep"
            ];
            max_ratio = -1;
            max_seeding_time = -1;
            last_active = 0;
            limit_upload_speed = 0;
            cleanup = false;
            resume_torrent_after_change = true;
            add_group_to_tag = true;
            min_num_seeds = 0;
          };
          health = {
            priority = 2;
            categories = [
              "buffer"
              "cross-seed"
            ];
            max_ratio = -1;
            max_seeding_time = -1;
            last_active = 0;
            limit_upload_speed = 0;
            cleanup = false;
            resume_torrent_after_change = true;
            add_group_to_tag = true;
            min_num_seeds = 0;
          };
          unused = {
            priority = 3;
            include_any_tags = [
              "noHL"
            ];
            max_ratio = 5;
            min_seeding_time = "1 months";
            last_active = "1d";
            cleanup = true;
            resume_torrent_after_change = true;
            add_group_to_tag = true;
            min_num_seeds = 10;
          };
          active = {
            priority = 4;
            max_ratio = -1;
            min_seeding_time = 0;
            last_active = 0;
            cleanup = false;
            resume_torrent_after_change = true;
            add_group_to_tag = true;
            min_num_seeds = 0;
          };
        };

        recyclebin = {
          enabled = false;
          empty_after_x_days = 30;
          save_torrents = false;
          split_by_category = true;
        };

        orphaned = {
          empty_after_x_days = 30;
          exclude_patterns = [
            "**/.DS_Store"
            "**/Thumbs.db"
            "**/@eaDir"
            "/data/torrents/temp/**"
            "**/*.!qB"
            "**/*_unpackerred"
          ];
        };

        webhooks = {
          error = null;
          run_start = null;
          run_end = null;
          function = {
            cross_seed = null;
            recheck = null;
            cat_update = null;
            tag_update = null;
            rem_unregistered = null;
            tag_tracker_error = null;
            rem_orphaned = null;
            tag_nohardlinks = null;
            share_limits = null;
            cleanup_dirs = null;
          };
        };
      };
    };
}

