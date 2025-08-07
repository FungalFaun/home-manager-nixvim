{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = [
    pkgs.protonvpn-gui
  ];

  sops.secrets.wireless = {
    sopsFile = ../../secrets/secrets.yaml;
    neededForUsers = true;
  };

  networking.wireless = {
    enable = true;
    fallbackToWPA2 = false;

    # https://mynixos.com/nixpkgs/option/networking.wireless.secretsFile
    # TODO Fix sops before use!
    secretsFile = config.sops.secrets.wireless.path;

    # Example
    networks = {
      "Bivrost" = {
        pskRaw = "From sops file";
      };
    };

    # Allow imperative (wpa_gui) config
    allowAuxiliaryImperativeNetworks = true;
    extraConfig = ''
      ctrl_interface=DIR=/run/wpa_supplicant GROUP=${config.users.groups.network.name}
      update_config=1
    '';
  };

  users.groups.network = {};
  systemd.services.wpa_supplicant.preStart = "touch /etc/wpa_supplicant.conf";
}
