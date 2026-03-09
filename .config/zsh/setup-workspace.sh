#!/bin/bash

# Agentic dev workspace layout
# Left (65%): nvim
# Top-right: Claude Code agent
# Bottom-right: shell for git/builds

PROJECT="${1:-$(pwd)}"
SESSION="${2:-dev}"

# Kill existing session if present
tmux kill-session -t "$SESSION" 2>/dev/null

tmux new-session -d -s "$SESSION" -c "$PROJECT"
tmux send-keys "nvim" Enter

# Right side: agent + shell
tmux split-window -h -p 35 -c "$PROJECT"
tmux send-keys "claude" Enter

tmux split-window -v -p 30 -c "$PROJECT"

# Focus nvim
tmux select-pane -t 0

tmux attach-session -t "$SESSION"
