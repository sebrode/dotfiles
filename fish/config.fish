if status is-interactive
    # Commands to run in interactive sessions can go here
   wal -i ~/wallpapers/nice-blue-background.png
end


alias flake-update="sudo nix flake update --flake /home/seb/.config/nixos/ && sudo nixos-rebuild switch --flake /home/seb/.config/nixos/"

alias cdc="cd /home/seb/.config/nixos/"
alias cdhc="cd /home/seb/.config/hypr/"

alias sebdrive="cd /mnt/SebDrive/SynologyDrive/"


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


alias sex-og-vodka="bash /home/seb/scripts/sex-og-vodka.sh"
