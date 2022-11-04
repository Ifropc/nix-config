# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  jcef = import
    (builtins.fetchTarball https://github.com/GenericNerdyUsername/nixpkgs/tarball/jetbrains-jcef)
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
           ];

  environment.systemPackages = with pkgs; [
    # Basic tools
    wget git zsh ncdu killall gnupg

    zip unzip

    htop libnotify

    firefox-wayland 

    chromium 

    thunderbird
  
    jdk11 maven gradle

    slack openvpn jcef.jetbrains.idea-community jetbrains.clion 

    keybase kbfs keybase-gui 

    docker docker-compose

    neovim     

    wayland sway wlr-randr swaylock swayidle alacritty mako

    pipewire wireplumber pavucontrol
  
    spotify

    lorri direnv niv lldb 
  ];

  services.keybase.enable = true;
  services.kbfs.enable = true;

  programs.sway = { enable = true; };
  
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
