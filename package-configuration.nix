# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
  
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
  systemctl --user stop pipewire xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };
in {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
             "idea-ultimate"
             "idea-community"
	     "clion"
	     "rust-rover"
	     "slack"
	     "spotify-unwrapped"
	     "spotify"
	     "vscode"
	     "discord"
	];

  environment.systemPackages = with pkgs; [
    # Basic tools
    wget git zsh ncdu killall gnupg inetutils
 
    zip unzip

    htop libnotify

    firefox-wayland librewolf

    chromium 

    thunderbird
  
    jdk17 maven gradle

    nodejs yarn python3 

    gcc

    slack openvpn jetbrains.idea-community jetbrains.rust-rover 

    keybase kbfs keybase-gui 

    docker docker-compose

    neovim     

    wayland sway wlr-randr swaylock swayidle mako xdg-utils dbus-sway-environment wl-clipboard

    alacritty

    pipewire wireplumber pavucontrol
  
    spotify

    lorri direnv niv lldb 
  
    sshuttle

    discord
  
    nix-index nix-ld

    openssl
  
    ranger ueberzugpp mcomix mpv neofetch 

    speedtest-cli
 
    nixVersions.nix_2_20
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
  programs.java.package = pkgs.jdk17;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.nix-ld.enable = true;

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

  services.dbus.enable = true;
  
  xdg.portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make gtk apps happy
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  
  fonts = {
    enableDefaultPackages = true;
    
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      dina-font
      proggyfonts
      ipafont
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [
          "Noto Color Emoji"
        ];
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
    };
  };
    
  nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
}
