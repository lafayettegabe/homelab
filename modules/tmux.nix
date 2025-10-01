{ config, pkgs, lib, ... }:
{
  environment.etc."tmux.conf" = {
    text = ''
# ─── 1) TPM & Plugins ─────────────────────────────────────────────────────────
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
run '~/.tmux/plugins/tpm/tpm'

# ─── 2) Basic Settings ────────────────────────────────────────────────────────
set -g base-index 1
setw -g pane-base-index 1

set -g mouse on
setw -g mode-keys vi
#set -g status-position top // not using rn need some padding

# ─── 3) Pane Borders ──────────────────────────────────────────────────────────
set -g pane-border-style        fg=colour241
set -g pane-active-border-style fg=colour111

# ─── 4) Transparent Status Bar ───────────────────────────────────────────────
set -g status on
set -g status-interval 5
set -g status-justify centre
set -g status-style bg=default,fg=colour136

# ─── 5) Left Segment: Session Name ───────────────────────────────────────────
set -g status-left-length 32
set -g status-left "#[fg=colour109,bg=default]#[fg=colour235,bg=colour109] #S #[fg=colour109,bg=default]"

# ─── 6) Window List ───────────────────────────────────────────────────────────
setw -g window-status-format        "#[fg=colour244,bg=default] #I:#W "
setw -g window-status-current-format "#[fg=colour109,bg=default]#[fg=colour235,bg=colour109] #I:#W #[fg=colour109,bg=default]"

# ─── 7) Right Segment: Date & Time ───────────────────────────────────────────
set -g status-right-length 150
set -g status-right "#[fg=colour136,bg=default]#[fg=colour235,bg=colour136] %Y-%m-%d  %H:%M #[fg=colour136,bg=default]"

# ─── 8) Reload Shortcut ──────────────────────────────────────────────────────
bind r source-file ~/.tmux.conf \; display-message "🔄 tmux.conf reloaded!"

# ─── 9) Use Default Ctrl+b as Prefix ──────────────────────────────────────────
# C-b is the default prefix, no changes needed

# ─── 10) Key Shortcuts ────────────────────────────────────────────────────────
set -s escape-time 0

# Split panes with Ctrl+b + | or Ctrl+b + -
bind | split-window -h
bind - split-window -v

# Move between panes with Ctrl+b + Arrow Keys
bind Left select-pane -L
bind Right select-pane -R
bind Up select-pane -U
bind Down select-pane -D
'';
    mode = "0644";
  };

  system.activationScripts.tmuxConfig = ''
    mkdir -p /home/server1
    ln -sf /etc/tmux.conf /home/server1/.tmux.conf
    chown server1:users /home/server1/.tmux.conf
  '';
}
