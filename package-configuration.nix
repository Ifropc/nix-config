# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {} ;

    # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };

  jcef = import
    (builtins.fetchTarball https://github.com/GenericNerdyUsername/nixpkgs/tarball/d2231fc94faf42ba057f4c8d210d95fae65d073c)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
             "idea-ultimate"
             "idea-community"
	     "clion"
	     "slack"
	     "spotify-unwrapped"
	     "spotify"
	     "vscode"
           ];

  environment.systemPackages = with pkgs; [
    # Basic tools
    wget git zsh ncdu killall gnupg inetutils
 
    zip unzip

    htop libnotify

    firefox-wayland 

    chromium 

    thunderbird
  
    jdk11 maven gradle

    nodejs yarn 

    slack openvpn jcef.jetbrains.idea-ultimate jcef.jetbrains.idea-community vscode 

    keybase kbfs keybase-gui 

    docker docker-compose

    neovim     

    wayland sway wlr-randr swaylock swayidle alacritty mako xdg-utils dbus-sway-environment

    pipewire wireplumber pavucontrol
  
    spotify

    lorri direnv niv lldb 
  
    sshuttle
  ];

  services.keybase.enable = true;
  services.kbfs.enable = true;

  programs.sway = { 
    enable = true; 
   
    extraPackages = with pkgs; [
      flameshot
      dmenu
    ];
 
    extraSessionCommands = ''
      export MOZ_ENABLE_WAYLAND=1
      export MOZ_USE_XINPUT2=1
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
      export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export QT_QPA_PLATFORM=wayland
      export XDG_SESSION_DESKTOP=sway
      export SDL_VIDEODRIVER=wayland
      export NIXOS_OZONE_WL=1
    '';
  };
  
  programs.neovim = {
     enable = true;
     viAlias = true;
     vimAlias = true;
  };

  programs.gnupg.agent.enable = true;

  programs.java.enable = true;
  programs.java.package = pkgs.jdk11;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  #services.mysql.enable = true;
  #services.mysql.package = pkgs.mariadb;
 
  virtualisation.docker.enable = true;

  nix.extraOptions = ''experimental-features = nix-command flakes'';

  hardware.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.pipewire  = {
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
      }
    ];
  };

  services.dbus.enable = true;
  
  xdg.portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make gtk apps happy
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
    ipafont
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "DejaVu Sans"
      "IPAPGothic"
    ];
    serif = [
      "DejaVu Serif"
      "IPAPMincho"
    ];
  };

  nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
}
