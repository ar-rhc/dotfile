#!/bin/bash

# Dynamically generate a tmux menu of all active sessions
# Based on the autodidactics blog post method.

tmux list-sessions -F '#S' \
| awk 'BEGIN {ORS=" "} {print $1, NR, "\"switch-client -t", $1 "\""}' \
| xargs tmux display-menu -T "Switch session"
