if status is-interactive
    # Commands to run in interactive sessions can go here
    #wal -i ~/wallpapers/nice-blue-background.png > /dev/null 2>&1 &
end




alias eduroam 'nix-shell -p "python3.withPackages (ps: with ps; [ dbus-python ])" --run "python3 $HOME/Downloads/eduroam-linux-UoC.py"'


alias flake-update="sudo nix flake update --flake /home/seb/.config/nixos/ && sudo nixos-rebuild switch --flake /home/seb/.config/nixos/"

alias cdc="cd /home/seb/.config/nixos/"
alias cdhc="cd /home/seb/.config/hypr/"

alias sebdrive="cd /mnt/SynologyDrive/"


function nix-python-shell
    if test -e shell.nix
        echo "A shell.nix file already exists in this directory."
    else
        cp /home/seb/pythonShell/shell.nix .
        echo "shell.nix has been copied to the current directory."
    end
end


function fish_prompt
    # Check if we're inside a nix shell.
    if test -n "$INSIDE_NIX_SHELL"
        set prefix "[Nix Shell]"
    else
	set prefix ""
    end

    # Build a prompt. This is a simple example; feel free to customize it.
    set user (whoami)
    set host (hostname)
    set cwd (prompt_pwd)
    set_color normal
    echo -n $prefix$user"@"$host""$cwd"> "
end


# Android SDK (local)
set -x ANDROID_SDK_ROOT $HOME/Android/Sdk
set -x ANDROID_HOME    $ANDROID_SDK_ROOT

fish_add_path -g \
  $ANDROID_SDK_ROOT/cmdline-tools/latest/bin \
  $ANDROID_SDK_ROOT/platform-tools \
  $ANDROID_SDK_ROOT/emulator

# Java (for Android SDK tools)
set -x JAVA_HOME (dirname (dirname (readlink -f (which java))))
fish_add_path -g $JAVA_HOME/bin

# Cargo-installed binaries
fish_add_path -g $HOME/.cargo/bin



alias sex-og-vodka="bash /home/seb/scripts/sex-og-vodka.sh"
