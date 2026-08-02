#!/bin/bash
# Finder does not expose a reliable deletion-history order, so open Trash and
# let the user choose the exact item to restore.
open "$HOME/.Trash"
