{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./plasma.nix
    ./disko.nix
    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";

  # Boot UEFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Racine éphémère en RAM
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=25%"
      "mode=755"
    ];
  };

  ## Useful to mount /home/user as user
  # fileSystems."/home/user" = {
  #   device = "none";
  #   fsType = "tmpfs";
  #   options = [
  #     "size=2G"
  #     "mode=700"
  #     "uid=1000"
  #     "gid=100"
  #   ];
  # };

  # OR use systemd
  #  systemd.tmpfiles.rules = [
  #    "d /nix/persist/home/user 0700 user users -"
  #    "z /nix/persist/home/user 0700 user users -"
  #    "d /home/user 0700 user users -"
  #    "z /home/user 0700 user users -"
  #  ];

  # Identité et paramètres de base
  networking.hostName = "g3";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Zurich";
  console.keyMap = "fr";

  i18n.defaultLocale = "fr_FR.UTF-8";

  # Outils de diagnostic
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    btop
    pciutils
    usbutils
    cloudflared
    openssl
    tcpdump
    cowsay
    lolcat
    bat
  ];

  environment.persistence."/nix/persist" = {
    hideMounts = true;

    directories = [
      "/var/lib/nixos"
      "/var/log"
      "/etc/cloudflared"
    ];

    files = [
      "/etc/machine-id"
    ];

    users.user = {
      directories = [
        ".config"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        ".local/share/direnv"
        {
          directory = "workspace";
          mode = "0700";
        }
      ];
      files = [
        ".bash_history"
        ".gitconfig"
      ];
    };
  };

  users.mutableUsers = false;
  users.users.user = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    home = "/home/user";
    createHome = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1oFq0GYt8j7vg2nNAJNzwBtqrdOUDp8CMQwLRiz4Vz user@ull"
    ];

    # Use mkpasswd
    initialHashedPassword = "$y$j9T$TvYwvyoJ.v1jj64tTF5K61$jDWwkEw/owyBks.6xLwYIlKcLD4MJ4G062UAm757N/4";
  };

  users.users.colmena = {
    isNormalUser = true;
    home = "/var/lib/colmena";
    createHome = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1oFq0GYt8j7vg2nNAJNzwBtqrdOUDp8CMQwLRiz4Vz user@ull"
    ];
  };

  nix.settings.trusted-users = [
    "root"
    "colmena"
  ];

  security.sudo.extraRules = [
    {
      users = [ "colmena" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.sudo.wheelNeedsPassword = true;

  # KDE Plasma 6
  # services.desktopManager.plasma6.enable = true;

  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };

  # services.xserver.xkb.layout = "fr";

  services.openssh = {
    enable = true;
    #logLevel = "DEBUG3";
    openFirewall = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
    };

    hostKeys = [
      {
        path = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  services.caddy = {
    enable = true;

    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/daaku/caddy-ssh@v0.10.0"
      ];

      hash = "sha256-MhzeZOj4qOIKDwGg0Poz6IAsh+OvSWxIBeSrBwU4NXo=";
    };

    virtualHosts."g3.proxlab.cc:8443" = {
      extraConfig = ''
        tls internal

        route {
          ssh 127.0.0.1:22
          respond "Not found" 404
        }
      '';
    };

  };

  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/cloudflared tunnel run --token-file /etc/cloudflared/token";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
