#!/bin/bash

# Enhanced Tmux Layout Script
# Detects if you are already inside Tmux and switches sessions gracefully.

# Use the current folder name as the session name
SESSION_NAME=$(basename "$PWD" | tr . _)

# Function to create the session if it doesn't exist
create_session() {
    # 1. Create the session and the first window ("code")
    tmux new-session -d -s "$SESSION_NAME" -n "code"
    
    # 2. Split the "code" window (70% main, 30% side panel)
    tmux split-window -h -p 30 -t "$SESSION_NAME:code"
    
    # 3. Create a dedicated "git" window running lazygit
    tmux new-window -t "$SESSION_NAME" -n "git"
    tmux send-keys -t "$SESSION_NAME:git" "lazygit" C-m
    
    # 4. Finalize: select the main code pane
    tmux select-window -t "$SESSION_NAME:code"
    tmux select-pane -t 0
}

# --- Main Logic ---

if [ -n "$TMUX" ]; then
    # CASE 1: You are ALREADY inside a Tmux session
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        create_session
    fi
    
    # Switch the current client to the project session
    tmux switch-client -t "$SESSION_NAME"
else
    # CASE 2: You are in a regular shell (not in Tmux)
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        create_session
    fi
    
    # Attach to the session
    tmux attach-session -t "$SESSION_NAME"
fi
