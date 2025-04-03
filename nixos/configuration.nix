{ inputs, config, pkgs, unstablePkgs, ... }:

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

  nixpkgs.config = {
    allowUnfree = true;
  };


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
  services.xserver.xkb = {
    layout  = "dk";
    variant = "";
  };

  console.keyMap = "dk-latin1";
  services.printing.enable = true;

  # Bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  hardware.graphics.enable = true;

  # Audio and multimedia (using PipeWire).
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable           = true;
    alsa.enable      = true;
    alsa.support32Bit = true;
    pulse.enable     = true;
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

  # Enable experimental features.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nix.settings = {
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
    bitwarden
    blueberry
    blueman
    brightnessctl
    copyq
    discord
    docker
    dotnet-sdk
    dotnetCorePackages.sdk_8_0_3xx
    dotnetPackages.Nuget
    drawio
    driversi686Linux.mesa
    feh
    fd
    freetype
    freeglut
    fzf
    gcc
    ghostty
    gimp
    git
    glew
    glib
    glm
    glfw
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
    i3
    inetutils
    jetbrains-toolbox
    jupyter
    libcxx
    libgcc
    libGL
    libglvnd
    libreoffice
    light
    lm_sensors
    lsof
    mgba
    mpv
    neofetch
    neovim
    nix-tree
    mesa
    mono
    networkmanagerapplet
    nix-ld
    nodejs
    nodePackages."@angular/cli"
    ollama
    patchelf
    pavucontrol
    playerctl
    psmisc
    python312
    python312Packages.numpy
    python312Packages.pandas
    python312Packages.virtualenv
    pywal
    pywalfox-native
    rofi
    rofimoji
    SDL2
    SDL2_image
    spotify
    steam  
    swww
    synology-drive-client
    teams-for-linux
    typescript
    xfce.thunar
    unityhub
    unixtools.ifconfig
    unixtools.netstat
    unzip
    vim
    vscode
    waybar
    wget
    wofi
    konsole
    kitty
    alacritty
  ];

  # Fonts configuration.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerdfonts
    roboto
    fira-code-nerdfont
    font-awesome
    powerline-fonts
    powerline-symbols
  ];

  # Set the system state version.
  system.stateVersion = "24.11";

  environment.etc."share/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=Hyprland session
    Exec=hyprland
    Type=Application
  '';
}
