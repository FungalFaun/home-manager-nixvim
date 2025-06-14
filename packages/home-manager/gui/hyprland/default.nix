{ lib,
  config,
  pkgs,
  ...
}: let
#  getHostname = x: lib.last (lib.splitString "@" x);
#  rgb = color: "rgb(${lib.removePrefix "#" color})";
#  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";
  cfg = config.programs.hypreco;
in {
  imports = [
    ./hyprpaper.nix
    ./hypridle.nix
  ];

  options.programs.hypreco = {
    enable = lib.mkEnableOption "Hypr ecosystem";
  };

  config = lib.mkIf cfg.enable {
    # Might not be necessary, but might help compatibility
    programs.kitty.enable = true;

    xdg.portal = let
      hyprland = config.wayland.windowManager.hyprland.package;
      xdph = pkgs.xdg-desktop-portal-hyprland.override {inherit hyprland;};
    in {
      extraPortals = [xdph];
      configPackages = [hyprland];
    };

    home.packages = with pkgs; [
      grimblast
      hyprpicker

      hyprcursor
    ];

    home.sessionVariables = {
      "NIXOS_OZONE_WL" = 1;
  #    "XDG_SCREENSHOTS_DIR" = "/home/faun/Pictures/screenshots";
    };

    home.file = {
      ".local/share/icons/PhingerCursors".source = "${pkgs.phinger-cursors}";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland.override {wrapRuntimeDeps = false;};

      systemd = {
        enable = true;
        # Same as default, but stop graphical-session too
        extraCommands = lib.mkBefore [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };

      settings = {
        #monitor = ["eDP-1, 2880x1800@60, 0x0, 1.5"];

        monitor =
          []
          ++ (map (
            m: let 
              resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
              position = "${toString m.x}x${toString m.y}";
            in "${m.name}, ${
              if m.enabled
              then "${resolution}, ${position}, ${m.scaling}"
              else "disable"
            }"
          ) (config.monitors));

        env = [
          "HYPRCURSOR_THEME, phinger-cursors-light"
          "HYPRCURSOR_SIZE, 24"
          "XCURSOR_THEME, phinger-cursors-light"
          "XCURSOR_SIZE, 24"
        ];

        input = {
          kb_layout = "us";
          kb_variant = "altgr-intl";

          follow_mouse = 1;

          touchpad = {
            natural_scroll = true;
            "tap-to-click" = false;
            clickfinger_behavior = true;
          };

          sensitivity = 0;
        };

        general = {
          gaps_in = 3;
          gaps_out = 10;
          border_size = 1;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          layout = "dwindle";

          allow_tearing = false;
        };

        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 5;

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";

          };
        };

        animations = {
          enabled = true;

          bezier = [
            "myBezier, 0.05, 0.9, 0.1, 1.05"
          ];

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        gestures = {
          workspace_swipe = true;
        };

        misc = {
          force_default_wallpaper = 0;
        };

        "$mod" = "SUPER";

        bind = let
          grim = lib.getExe pkgs.grim;
          slurp = lib.getExe pkgs.slurp;
          wlcopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
          swayosd = lib.getExe' pkgs.swayosd "swayosd-client";
  #        notify-send = lib.getExe' pkgs.libnotify "notify-send";
  #        defaultApp = type: "${lib.getExe pkgs.handlr-regex} launch ${type}";
          wofi = lib.getExe config.programs.wofi.package;
          thunar = lib.getExe pkgs.xfce.thunar;
        in
          [
            "$mod, Q, exec, alacritty"
            "$mod, W, exec, firefox"
            "$mod & CTRL, W, exec, firefox -private-window"
            "$mod, T, exec, telegram-desktop"

            "$mod, space, exec, ${wofi} --show drun"

            "ALT, C, killactive, "
            "ALT, M, exit, "
            "$mod, E, exec, ${thunar}"
            "$mod, V, togglefloating, "
            "$mod, P, pseudo, # dwindle"
            "$mod, J, togglesplit, "

            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"

            #            "$mod, S, togglespecialworkspace, magic"
            #            "$mod SHIFT, S, movetoworkspace, special:magic"

            #"$mod, S, ${grim} -g ${slurp} - | ${wlcopy}"

            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"

            #            "$mod, M, exec, ${grimblast} --notify --freeze copysave area"
            #            "$mod SHIFT, M, exec, ${grimblast} --notify --freeze copysave output"

            " , XF86AudioMute, exec, ${swayosd} --output-volume mute-toggle"
          ]
          ++ (builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10));

        binde = let
          swayosd = lib.getExe' pkgs.swayosd "swayosd-client";
        in [
          " , XF86AudioRaiseVolume, exec, ${swayosd} --output-volume raise --max-volume 180"
          " , XF86AudioLowerVolume, exec, ${swayosd} --output-volume lower --max-volume 180"

          " , XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          " , XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          " CTRL, XF86MonBrightnessUp, exec, brightnessctl set 1%+"
          " CTRL, XF86MonBrightnessDown, exec, brightnessctl set 1%-"

          " SHIFT, XF86MonBrightnessUp, exec, brightnessctl set 20%+"
          " SHIFT, XF86MonBrightnessDown, exec, brightnessctl set 20%-"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

      };
    };
  };
}
