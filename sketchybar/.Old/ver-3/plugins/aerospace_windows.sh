#!/bin/bash

source $CONFIG_DIR/utils/aerospace.sh

# Function to update all workspace icons
update_all_workspaces() {
    local all_workspace_data=$(aerospace list-windows --monitor all --format "%{workspace}|%{app-name}")
    local focused_workspace=$(aerospace list-workspaces --focused)
    local active_workspaces=$(extract_unique_workspaces "$all_workspace_data")
    active_workspaces=$(include_focused_workspace "$active_workspaces" "$focused_workspace")
    
    local updates=""
    
    # Update all active workspaces
    for workspace_id in $active_workspaces; do
        if [[ -n "$workspace_id" ]] && sketchybar_item_exists "workspace.$workspace_id"; then
            # Determine if this is the focused workspace
            if [[ "$workspace_id" == "$focused_workspace" ]]; then
                updates+="--set workspace.$workspace_id \
                               drawing=on \
                               ${workspace_active_style[*]} \
                               label=\"$(workspace_app_icons $workspace_id)\" "
            else
                # Check if workspace has windows
                local monitor_id=$(get_workspace_monitor_id "$workspace_id")
                if [[ -n "$monitor_id" ]]; then
                    updates+="--set workspace.$workspace_id \
                                   drawing=on \
                                   ${workspace_inactive_style[*]} \
                                   label=\"$(workspace_app_icons $workspace_id)\" "
                else
                    updates+="--set workspace.$workspace_id \
                                   drawing=off \
                                   label=\" —\" "
                fi
            fi
        fi
    done
    
    # Execute batched command
    if [[ -n "$updates" ]]; then
        eval "sketchybar $updates"
    fi
}

if [[ "$SENDER" = "change-window-workspace" ]]; then

    # Batch workspace updates for better performance but use existing function for correctness
    local updates=""
    
    # Track if target workspace was created
    local target_created=false
    
    # Build updates for focused workspace (already exists)
    if [[ "$FOCUSED_WORKSPACE" ]]; then
      updates+="--set workspace.$FOCUSED_WORKSPACE \
                     drawing=on \
                     ${workspace_active_style[*]} \
                     label=\"$(workspace_app_icons $FOCUSED_WORKSPACE)\" "
    fi
    
    # Build updates for target workspace (create if it doesn't exist)
    if [[ "$TARGET_WORKSPACE" ]]; then
      if ! sketchybar_item_exists "workspace.$TARGET_WORKSPACE"; then
        create_and_position_workspace "$TARGET_WORKSPACE"
        target_created=true
      fi
      updates+="--set workspace.$TARGET_WORKSPACE \
                     drawing=on \
                     ${workspace_inactive_style[*]} \
                     label=\"$(workspace_app_icons $TARGET_WORKSPACE)\" "
    fi
    
    # Execute batched command
    if [[ -n "$updates" ]]; then
      eval "sketchybar $updates"
    fi
    
elif [ "$SENDER" = "aerospace_workspace_change" ]; then
  handle_workspace_change
elif [[ "$SENDER" = "change-workspace-monitor" ]]; then
  sketchybar --set workspace.$TARGET_WORKSPACE display=$TARGET_MONITOR
elif [[ "$SENDER" = "front_app_switched" ]] || [[ "$SENDER" = "space_windows_change" ]]; then
  # Update all workspaces when front app changes or windows change
  update_all_workspaces
fi
