#!/bin/bash

load_config_version() {
  local tmux_home=~/.tmux
  local tmux_version="$(tmux -V | cut -c 6-)"

  if [[ $(echo "$tmux_version >= 2.0" | bc) -eq 1 ]] ; then
    tmux source-file "$tmux_home/v2.x.conf"
  else
    tmux source-file "$tmux_home/v1.9.conf"
  fi
}

load_config_version
