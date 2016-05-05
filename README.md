dotserver
=========
This repository contains dotfiles for headless systems.

Includes:
- dircolors
- bash config
- tmux config
- vim config

installation
------------

    git clone https://github.com/martinohmann/dotserver.git ~/.dotserver
    ~/.dotserver/install.sh --backup

Run `~/.dotserver/install.sh --help` to see all install options.

updating
--------

    cd ~/.dotserver
    git pull

If you did not use the `--symlink` option you have to run `install.sh` again to
apply the changes in dotserver to your user account.

