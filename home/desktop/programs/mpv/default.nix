{pkgs, ...}: {
  programs.mpv = {
    enable = true;

    scripts = with pkgs.mpvScripts; [
      mpris
      thumbfast
      autoload
      seekTo
      reload
      visualizer
      mpv-cheatsheet
      webtorrent-mpv-hook
      uosc
    ];

    bindings = {
      WHEEL_UP = "add volume  2";
      WHEEL_DOWN = "add volume -2";
      "Ctrl+WHEEL_UP" = "add sub-scale  0.1";
      g = "add sub-scale -0.1";
      "[" = "add speed -0.25";
      "]" = "add speed  0.25";
      "Ctrl+[ " = "add speed -0.05";
      "Ctrl+]" = "add speed  0.05";
      "Ctrl+t" = "cycle ontop";
      "Ctrl+r" = "cycle-values video-rotate '90' '180' '270' '0'";
      "b" = "cycle-values deband 'yes' 'no'";
      "B" = "cycle-values deband-iterations '1' '2' '3'; cycle-values deband-threshold '35' '60' '100'; cycle-values deband-range '16' '20' '25'; cycle-values deband-grain '5' '24' '48'; show-text 'Deband: \${deband-iterations}:\${deband-threshold}:\${deband-range}:\${deband-grain}'";
      h = "cycle-values hr-seek 'default' 'yes'";
      x = "apply-profile hq; show-text 'Profile: HQ'";
      X = "apply-profile hq restore; show-text 'Profile: Default'";
      d = "vf del -1";
      "Shift+q" = "set save-position-on-quit no; quit; delete-watch-later-config";

      # Default seek using arrow keys (5s and 60s)
      RIGHT = "no-osd seek  5";
      LEFT = "no-osd seek -5";
      # Shift enables smaller seek (1s and 30s)
      "Shift+UP" = "seek  30";
      "Shift+DOWN" = "seek -30";
      # Ctrl enables alternative seek (10s and sub-seek)
      "Ctrl+RIGHT" = "seek  10";
      "Ctrl+LEFT" = "seek -10";
      "Ctrl+UP" = "no-osd sub-seek  1";
      "Ctrl+DOWN" = "no-osd sub-seek -1";

      # Script Keybinds #
      DEL = "script-binding modernx/visibility";
      "Shift+DEL" = "script-message-to modernx osc-visibility auto";
      c = "script-message-to crop start-crop";
      t = "script-message-to seek_to toggle-seeker";
      F2 = "cycle-values af 'lavfi=[loudnorm=I=-16:TP=-3:LRA=4]' 'lavfi=[dynaudnorm=f=75:g=25:p=0.55]'";
    };

    config = {
      # OSC
      osc = false;
      osd-font = "MesloLGS Nerd Font";
      osd-font-size = 30;
      osd-color = "#C0FFFFFF";

      # Player
      border = false;
      keep-open = true;
      snap-window = true;
      autofit = "85%x85%";
      cursor-autohide = 1000;
      audio-pitch-correction = true;
      save-position-on-quit = true;
      watch-later-options-remove = "sub-pos";
      fullscreen = false;
      hwdec = "auto";

      # Audio
      alang = "eng";
      volume = 80;
      volume-max = 120;
      mute = false;
      audio-file-auto = "fuzzy"; # Load additional audio files containing the video filename
      audio-channels = "stereo";

      # Subs
      sub-font = "MesloLGS Nerd Font";
      sub-bold = false;
      sub-font-size = 25;
      sub-blur = 1;
      sub-auto = "fuzzy"; # Load additional subtitle files containing the video filename
      demuxer-mkv-subtitle-preroll = true; # Try to correctly show embedded subs when seeking
      sub-margin-y = 5;
      stretch-image-subs-to-screen = true;
      slang = builtins.concatStringsSep "," ["eng" "en"]; # Prioritise which subtitle language to use
      sub-pos = 100;

      # Screenshots
      ## %X is the fallback path if the video is not on the filesystem, like YouTube streams.
      ## The template is basically: "Video Name [HH.MM.SS.MS].png"
      screenshot-template = "%X{~~desktop/}%F [%wH.%wM.%wS.%wT]";
      screenshot-format = "png";
      screenshot-tag-colorspace = true; # Tag screenshots with the appropriate colorspace
      screenshot-high-bit-depth = true;
      screenshot-png-compression = 5;

      # Terminal
      msg-color = true;
      msg-module = true;
    };

    profiles = {
      lazy = {
        profile = "gpu-hq";
        vo = "gpu-next";
        hwdec = "auto-copy-safe";
        pause = true;
      };
    };

    scriptOpts = {
      osc = {
        # Duration of fade out in ms
        fadeduration = 500;

        # Size ratio of the knob handle
        seekbarhandlesize = 1;

        # Outline width of the tooltips
        tooltipborder = 0.5;

        # Use unicode minus sign character
        unicodeminus = true;
      };

      console = {
        font = "MesloLGS Nerd Font";
        font_size = 18;
      };

      playlistmanager = {
        #### ------- Mpv-Playlistmanager configuration ------- ####

        #### ------- FUNCTIONAL ------- ####

        #navigation keybindings force override only while playlist is visible
        #if "no" then you can display the playlist by any of the navigation keys
        dynamic_binds = true;

        # To bind multiple keys separate them by a space

        # main key
        key_showplaylist = "SHIFT+ENTER";

        # dynamic keys
        key_moveup = "UP";
        key_movedown = "DOWN";
        key_movepageup = "PGUP";
        key_movepagedown = "PGDWN";
        key_movebegin = "HOME";
        key_moveend = "END";
        key_selectfile = "RIGHT LEFT";
        key_unselectfile = "";
        key_playfile = "ENTER";
        key_removefile = "BS";
        key_closeplaylist = "ESC";

        # extra functionality keys
        key_sortplaylist = "CTRL+A";
        key_shuffleplaylist = "CTRL+L";
        key_reverseplaylist = "CTRL+R";
        key_loadfiles = "P";
        key_saveplaylist = "p";

        #json format for replacing, check .lua for explanation
        #example json=[{"ext":{"all":true},"rules":[{"_":" "}]},{"ext":{"mp4":true,"mkv":true},"rules":[{"^(.+)%..+$":"%1"},{"%s*[%[%(].-[%]%)]%s*":""},{"(%w)%.(%w)":"%1 %2"}]},{"protocol":{"http":true,"https":true},"rules":[{"^%a+://w*%.?":""}]}]
        #empty for no replace
        filename_replace = "";

        #filetypes to search from directory
        loadfiles_filetypes = builtins.concatStringsSep "," ["jpg" "jpeg" "png" "tif" "tiff" "gif" "webp" "svg" "bmp" "mp3" "wav" "ogm" "flac" "m4a" "wma" "ogg" "opus" "mkv" "avi" "mp4" "ogv" "webm" "rmvb" "flv" "wmv" "mpeg" "mpg" "m4v" "3gp" "ivf"];

        #loadfiles at startup if 1 or more items in playlist
        loadfiles_on_start = false;

        #loadfiles from working directory on idle startup
        loadfiles_on_idle_start = false;

        #always put loaded files after currently playing file
        loadfiles_always_append = false;

        #sort playlist on mpv start
        # sortplaylist_on_start=no

        #sort playlist when any files are added to playlist after initial load
        sortplaylist_on_file_add = false;

        #yes: use alphanumerical sort comparison(nonpadded numbers in order), no: use normal lua string comparison
        # alphanumsort=yes

        #linux | windows | auto
        system = "auto";

        #Use ~ for home directory. Leave as empty to use mpv/playlists
        playlist_savepath = "./";

        #save playlist automatically after current file was unloaded
        save_playlist_on_file_end = false;

        #2 shows playlist, 1 shows current file(filename strip applied), 0 shows nothing
        show_playlist_on_fileload = 0;

        #sync cursor when file is loaded from outside reasons(file-ending, playlist-next shortcut etc.)
        sync_cursor_on_load = true;

        #playlist open key will toggle visibility instead of refresh
        # open_toggles=yes

        #allow the playlist cursor to loop from end to start and vice versa
        loop_cursor = true;

        #youtube-dl executable for title resolving if enabled, probably "youtube-dl" or "yt-dlp", can be absolute path
        youtube_dl_executable = "yt-dlp"; # TODO: home.packages.ytdlp

        #### ------- VISUAL ------- ####

        #prefer to display titles for following files: "all", "url", "none". Sorting still uses filename
        prefer_titles = "url";

        #call youtube-dl to resolve the titles of urls in the playlist
        # resolve_titles=yes

        #timeout in seconds for title resolving
        resolve_title_timeout = 15;

        #playlist timeout on inactivity, with high value on this open_toggles is good to be yes
        playlist_display_timeout = 5;

        #amount of entries to show before slicing. Optimal value depends on font/video size etc.
        showamount = 16;

        #font size scales by window, if no then needs larger font and padding sizes
        scale_playlist_by_window = true;
        #playlist ass style overrides
        #example {\fnUbuntu\fs10\b0\bord1} equals: font=Ubuntu, size=10, bold=no, border=1
        #read http://docs.aegisub.org/3.2/ASS_Tags/ for reference of tags
        #no values defaults to OSD settings in mpv.conf
        style_ass_tags = "{\fs10\blur1}";
        #paddings for top left corner
        text_padding_x = 10;
        text_padding_y = 30;

        #set title of window with stripped name
        set_title_stripped = false;
        title_prefix = "";
        title_suffix = " - mpv";

        #slice long filenames, and how many chars to show
        slice_longfilenames = false;
        slice_longfilenames_amount = 70;

        #Playing header. One newline will be added after the string.
        #%mediatitle or %filename = title or name of playing file
        #%pos = position of playing file
        #%cursor = position of navigation
        #%plen = playlist lenght
        #%N = newline
        playlist_header = "[%cursor/%plen]";

        #Playlist file templates
        #%pos = position of file with leading zeros
        #%name = title or name of file
        #%N = newline
        #you can also use the ass tags mentioned above. For example:
        #  selected_file={\c&HFF00FF&}➔ %name   | to add a color for selected file. However, if you
        #  use ass tags you need to reset them for every line (see https://github.com/jonniek/mpv-playlistmanager/issues/20)
        normal_file = "○ %name";
        hovered_file = "● %name";
        selected_file = "➔ %name";
        playing_file = "▷ %name";
        playing_hovered_file = "▶ %name";
        playing_selected_file = "➤ %name";

        #what to show when playlist is truncated
        playlist_sliced_prefix = "...";
        playlist_sliced_suffix = "...";

        #output visual feedback to OSD when saving, shuffling, reversing playlists
        display_osd_feedback = true;

        #reset cursor navigation when playlist is not visible
        reset_cursor_on_close = true;
      };

      reload = {
        # enable automatic reload on timeout
        # when paused-for-cache event is fired, we will wait
        # paused_for_cache_timer_timeout seconds and then reload the video
        paused_for_cache_timer_enabled = true;

        # checking paused_for_cache property interval in seconds,
        # cannot be less than 0.05 (50 ms)
        paused_for_cache_timer_interval = 1;

        # time in seconds to wait until reload
        paused_for_cache_timer_timeout = 10;

        # enable automatic reload based on demuxer cache
        # if demuxer-cache-time property didn't change in demuxer_cache_timer_timeout
        # time interval, the video will be reloaded as soon as demuxer cache is depleted
        demuxer_cache_timer_enabled = true;

        # checking demuxer-cache-time property interval in seconds,
        # cannot be less than 0.05 (50 ms)
        demuxer_cache_timer_interval = 2;

        # if demuxer cache didn't receive any data during demuxer_cache_timer_timeout,
        # we decide that it has no progress and will reload the stream when
        # paused_for_cache event happens
        demuxer_cache_timer_timeout = 20;

        # when the end-of-file is reached, reload the stream to check,
        # if there is more content available.
        reload_eof_enabled = false;

        # keybinding to reload stream from current time position
        # you can disable keybinding by setting it to empty value
        # reload_key_binding=
        reload_key_binding = "F5";
      };

      ytdl_hook = {
        try_ytdl_first = true;
        exclude = "\"%.mp4$|%.webm$|%.mkv$|%.m3u8?$\"";
      };
    };
  };

  # xdg.configFile = {
  #   "mpv/scripts/modernx.lua".source = ./modernx.lua;
  # };
}
