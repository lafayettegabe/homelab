{ config, pkgs, lib, ... }:
{
  # Tmux configuration
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

# ─── 9) Use Option (Meta) as Prefix ──────────────────────────────────────────
unbind C-b
set -g prefix M-b
bind M-b send-prefix

# ─── 10) Option Key Shortcuts ────────────────────────────────────────────────
set -s escape-time 0

# Split panes with Option + | or Option + -
bind | split-window -h
bind - split-window -v

# Move between panes with Option + Arrow Keys
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
'';
    mode = "0644";
  };

  # Create symlink for tmux config in user home
  system.activationScripts.tmuxConfig = ''
    mkdir -p /home/server_1
    ln -sf /etc/tmux.conf /home/server_1/.tmux.conf
    chown server_1:users /home/server_1/.tmux.conf
  '';
}
