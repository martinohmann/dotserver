#!/bin/bash

usage() {
  cat <<-EOS
installs dotserver to user's home directory

usage: $(basename "$0") [options]
  -h|--help             Show this help and exit.
  -f|--force            Overwrite existing files without confirmation.
  -b|--backup           Backup existing files. Backups will be suffixed
                        with '.pre-dotserver'.
EOS
}

confirm_installation() {
  read -p "Do you want to install dotserver? Existing files will be overwritten. (y|N) " yn
  case $yn in
    [Yy]) return ;;
    *) exit ;;
  esac
}

install() {

  [ $force -eq 1 ] || confirm_installation

  for f in ${files[@]}; do
    if [ -e "$HOME/$f" ]; then
      if [ $backup -eq 1 ]; then
        mv -f "$HOME/$f" "$HOME/$f.pre-dotserver"
      else
        rm -rf "$HOME/$f"
      fi
    fi
    ln -s "$dotserver/$f" "$HOME/$f"
  done
}

parse_args() {
  while [ $# -ge 1 ]; do
    case "$1" in
      -h|--help)
        usage
        exit ;;
      -f|--force)
        force=1 ;;
      -b|--backup)
        backup=1 ;;
      *)
        echo "invalid argument: $1. use -h to get a list of all valid options." 1>&2
        exit 1 ;;
    esac
    shift
  done
}

declare -a files

backup=0
dotserver="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
files=( .bashrc .vimrc .vim .tmux.conf .tmux )
force=0

parse_args "$@"
install

