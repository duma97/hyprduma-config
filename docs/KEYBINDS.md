# Hyprland Keybinds Cheatsheet

## Quick Reference Guide

### 🎮 System Controls

| Keybind | Action |
|---------|--------|
| `SUPER + C` | Close window |
| `SUPER + P` | Poweroff |
| `SUPER + RETURN` | Wlogout |
| `SUPER + M` | Exit Hyprland |
| `SUPER + L` | Caelestia lock, falling back to Hyprlock |
| `SUPER + Z` | Toggle floating |
| `SUPER + X` | Fullscreen |
| `SUPER + O` | Toggle split direction |
| `SUPER + SHIFT + O` | Toggle pseudo tiling for the focused window |
| `SUPER + SHIFT + B` | Toggle blur |
| `SUPER + N` | Toggle Caelestia sidebar (requires Caelestia) |

---

### 🚀 Applications

| Keybind | Application |
|---------|-------------|
| `SUPER + Q` | Terminal |
| `SUPER + F` | File Manager |
| `SUPER + B` | Browser |
| `SUPER + T` | Telegram |
| `SUPER + V` | VSCode |
| `SUPER + S` | Spotify |
| `SUPER + W` | Waypaper |
| `SUPER + R` | App Launcher |
| `SUPER + SHIFT + S` | Screenshot |
| `CTRL + SHIFT + ESCAPE` | Task Manager |

---

### 🪟 Window Management (ALT-based)

| Keybind | Action |
|---------|--------|
| `ALT + ←/→/↑/↓` or `ALT + H/L/K/J` | Move focus |
| `ALT + TAB` | Cycle windows |
| `SUPER + TAB` | Cycle windows backwards |
| `ALT + CTRL + ←/→/↑/↓` or `ALT + CTRL + H/L/K/J` | Resize window |
| `ALT + SHIFT + ←/→/↑/↓` or `ALT + SHIFT + H/L/K/J` | Move window |

---

### 🗂️ Workspace Management (SUPER-based)

#### Switch Workspace
| Keybind | Action |
|---------|--------|
| `SUPER + [1-9, 0]` | Go to workspace 1-10 |
| `SUPER + ←` | Previous workspace |
| `SUPER + →` | Next workspace |
| `SUPER + Scroll Up/Down` | Cycle workspaces |

#### Move Window to Workspace
| Keybind | Action |
|---------|--------|
| `SUPER + SHIFT + [1-9, 0]` | Move & follow |
| `SUPER + SHIFT + ←/→` or `SUPER + SHIFT + H/L` | Move to prev/next & follow |
| `SUPER + CTRL + [1-9, 0]` | Move silently (don't follow) |
| `SUPER + CTRL + ←/→` or `SUPER + CTRL + H/L` | Move to prev/next silently |

Plain `CTRL + H/L` is available to applications, including Neovim split navigation.

---

### 🖱️ Mouse Actions

| Action | Function |
|--------|----------|
| `SUPER + Left Click + Drag` | Move window |
| `SUPER + Right Click + Drag` | Resize window |
| `SUPER + Scroll` | Switch workspace |

---

### 🎵 Multimedia Keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up (5%) |
| `XF86AudioLowerVolume` | Volume down (5%) |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86AudioPlay/Pause` | Play/Pause |

---

### 👆 Touchpad Gestures

| Gesture | Action |
|---------|--------|
| 3-finger swipe horizontal | Switch workspace |
| 3-finger swipe vertical | Toggle fullscreen |

---

## Pro Tips

### Window Management Workflow
1. **Focus a window**: `ALT + Arrow Keys`
2. **Resize it**: `ALT + CTRL + Arrow Keys`
3. **Move it**: `ALT + SHIFT + Arrow Keys`
4. **Send to another workspace**: `SUPER + CTRL + [number]`
5. **Switch workspace**: `SUPER + [number]`

### Multi-Monitor Workflow
- Workspaces 1-4 are on external monitor (`DP-1`)
- Workspaces 5-10 are on laptop screen (`eDP-1`)
- Use `SUPER + SHIFT + [number]` to throw windows between monitors

### Screenshots
1. Press `SUPER + SHIFT + S`
2. Select area with mouse
3. Find in `~/Pictures/Screenshots/Screenshot_YYYY-MM-DD_HH:MM:SS.png`

---

## Keyboard Layout Toggle

| Keybind | Action |
|---------|--------|
| `ALT + SHIFT` | Switch between US and Russian |

---
