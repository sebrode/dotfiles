{ config, pkgs, lib, ... }:

{
  # Import hardware configuration.
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Bootloader settings.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname and networking.
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;



  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 5173 ];
  allowedUDPPortRanges = [
    # { from = 5000; to = 6000; }
  ];
};

  # nixpkgs.config = {
  #   allowUnfree = true;
  # };


  # Time zone and internationalisation.
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT    = "da_DK.UTF-8";
    LC_MONETARY       = "da_DK.UTF-8";
    LC_NAME           = "da_DK.UTF-8";
    LC_NUMERIC        = "da_DK.UTF-8";
    LC_PAPER          = "da_DK.UTF-8";
    LC_TELEPHONE      = "da_DK.UTF-8";
    LC_TIME           = "da_DK.UTF-8";
  };

  # X11 and desktop settings.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  #services.desktopManager.cosmic.enable = true;
  
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true; #battery management
  # services.displayManager.cosmic-greeter.enable = true;

  # services.xserver.desktopManager.gnome.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  
  programs.ssh.askPassword = lib.mkForce "/run/current-system/sw/bin/ksshaskpass";


  services.xserver.xkb = {
    layout  = "dk";
    variant = "";
  };

  console.keyMap = "dk-latin1";
  services.printing.enable = true;
  
  # Anti stutter / crash when ram is full
  services.swapspace.enable = true;

  
  # Bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Audio and multimedia (using PipeWire).
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable           = true;
    alsa.enable      = true;
    alsa.support32Bit = true;
    pulse.enable     = true;
    wireplumber.enable = true;
  };

  # User account.
  users.users.seb = {
    isNormalUser  = true;
    description   = "Seb's User";
    home          = "/home/seb";
    extraGroups   = [ "wheel" "networkmanager" "docker" ];
    shell         = pkgs.bash;
  };

  users.groups.seb = {
    gid = 1000;
  };


  nix.enable = true;

  nix.settings = {
    # Enable experimental features.
    experimental-features = [ "nix-command" "flakes" ];
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  # Automatic Garbage collection weekly
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
  };

  # Programs.
  programs.firefox.enable = true;

  programs.nix-ld.enable = false;
  programs.nix-ld.libraries = with pkgs; [

    # Add any missing dynamic libraries for unpackaged programs

    # here, NOT in environment.systemPackages
    dotnet-sdk
    dotnetPackages.Nuget

  ];

  # Enable hyprland, using the unstable package.
  programs.hyprland = {
    enable = true;
  };

  #Mariadb
  services.mysql = {
    enable = true;                    # turn on the server
    package = pkgs.mariadb;           # optional: ensure it’s the MariaDB flavor
    # Optionally, you can point to an initial SQL file to import at first boot:
    # initialScript = /path/to/surfveydb.sql;
  };


  virtualisation.docker.enable = true;
  

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.fish.enable = true;
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  

  # System packages.
  environment.systemPackages = with pkgs; [
    ani-skip
    anki
    bitwarden-desktop
    blueberry
    blueman
    brightnessctl
    cargo
    #chatgpt #macos only for now
    codex
    copyq
    dbeaver-bin
    discord
    docker
    dotnet-sdk
    dotnetCorePackages.sdk_9_0_1xx
    dotnetPackages.Nuget
    drawio
    driversi686Linux.mesa
    fastfetch
    feh
    fd
    ffmpeg
    ffmpeg_7
    ffmpeg_7-full
    file
    freetype
    freeglut
    fresh-editor
    fzf
    gcc
    ghostty
    git
    github-desktop
    glew
    glib
    glm
    glfw
    # gnome-shell
    # gnome-shell-extensions
    # gnome-control-center
    # gnome-settings-daemon
    nautilus
    # gnome-terminal
    # gnome-calculator
    # gnome-tweaks
    # gnome-system-monitor
    # gnomeExtensions.gtk4-desktop-icons-ng-ding
    # dconf-editor
    gnumake
    gtk2
    gtk3
    gtk4
    gtkd
    hblock
    hypridle
    hyprlock
    hyprpaper
    hyprpicker
    hyprshot
    htop
    inetutils
    jupyter
    jq
    libcxx
    libgcc
    libGL
    libglvnd
    libreoffice
    light
    lm_sensors
    #lutris
    lsof
    mgba
    mpv
    neovim
    nix-tree
    mariadb
    mesa
    mono
    networkmanagerapplet
    nix-ld
    nodejs
    nodePackages."@angular/cli"
    nwg-displays
    # ollama
    openjdk17
    patchelf
    pavucontrol
    # plex
    playerctl
    prismlauncher
    protonup-qt
    psmisc
    python312
    python312Packages.numpy
    python312Packages.pandas
    python312Packages.virtualenv
    pywal
    pywalfox-native
    rofi
    rofimoji
    rstudio
    rustc
    rustlings
    SDL2
    SDL2_image
    slack
    spotify
    spotifywm
    steam  
    swww
    synology-drive-client
    teams-for-linux
    tor
    tor-browser
    typescript
    #unityhub
    unixtools.ifconfig
    unixtools.netstat
    unzip
    vim
    vscode
    waybar
    wget
    wofi
    kdePackages.konsole
    kitty
    alacritty
    xclip
    xfce.thunar
    xorg.xprop
    zip
    zoom-us
  ];

  # Fonts configuration.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    roboto
    font-awesome
    powerline-fonts
    powerline-symbols
  ];

  # Set the system state version.
  system.stateVersion = "25.11";

  environment.etc."share/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=Hyprland session
    Exec=hyprland
    Type=Application
  '';
}
