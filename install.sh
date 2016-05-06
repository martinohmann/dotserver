#!/bin/bash

# list of files to install
declare -a dotserver_files=(
  .bashrc
  .dircolors
  .tmux
  .tmux.conf
  .vim
  .vimrc
)

usage() {
  cat <<-EOS
installs dotserver to user's home directory

usage: $(basename "$0") [options]
  -h|--help             Show this help and exit.
  -f|--force            Overwrite existing files without confirmation.
  -b|--backup           Backup existing files. Backups will be suffixed
                        with '.pre-dotserver'.
  -d|--dryrun           Execute without actually installing files.
  -s|--symlink          Symlink files instead of copying.
EOS
}

confirm_installation() {
  read -p "Do you want to install dotserver? Existing files will be overwritten. [y|N] " yn
  case $yn in
    [Yy]) return ;;
    *) echo "installation aborted"; exit ;;
  esac
}

install() {
  [ $dryrun -eq 1 ] || [ $force -eq 1 ] || confirm_installation

  if [ $dryrun -eq 0 ]; then
    echo "initializing submodules"
    pushd "$dotserver" > /dev/null 2>&1
    git submodule update --init --recursive
    popd > /dev/null 2>&1
  fi

  for f in ${dotserver_files[@]}; do
    if [ -e "$HOME/$f" ]; then
      if [ $backup -eq 1 ]; then
        echo "backing up $HOME/$f to $HOME/$f.pre-dotserver"
        [ $dryrun -eq 1 ] || mv -f "$HOME/$f" "$HOME/$f.pre-dotserver"
      else
        echo "removing $HOME/$f"
        [ $dryrun -eq 1 ] || rm -rf "$HOME/$f"
      fi
    fi
    echo "installing $dotserver/$f to $HOME/$f"
    if [ $dryrun -eq 0 ]; then
      if [ $symlink -eq 1 ]; then
        ln -s "$dotserver/$f" "$HOME/$f"
      else
        cp -r "$dotserver/$f" "$HOME/$f"
      fi
    fi
  done

  if [ $dryrun -eq 1 ]; then
    echo "dryrun: nothing was installed"
  else
    echo "installation finished"
  fi
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
      -d|--dryrun)
        dryrun=1 ;;
      -s|--symlink)
        symlink=1 ;;
      *)
        echo "invalid argument: $1. use -h to get a list of all valid options." 1>&2
        exit 1 ;;
    esac
    shift
  done
}

backup=0
dotserver="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dryrun=0
force=0
symlink=0

parse_args "$@"
install

