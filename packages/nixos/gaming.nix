{
  pkgs,
  ...
}: {
  services.xserver.videoDrivers = ["amdgpu"];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    enableAllFirmware = true;
    #nvidia = {
    #  modesetting.enable = true;
    #  powerManagement.enable = false;
    #  open = false;
    #  nvidiaSettings = true;
    #};
  };

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gamemode = {
      enable = true;

      settings = {
        general = {
          softrealtime = "on";
          inhibit_screensaver = 1;
        };

        gpu = {
          apply_gpy_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      mangohud
      # nexusmods-app-unfree
      protontricks
    ];
    
    # sessionVariables = {
    #   STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    # };
  };
}
