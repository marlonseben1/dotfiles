# Fedora Dotfiles 🚀

This is my personal config for Fedora 44 KDE Plasma

## ⚙️ What's Installed?

- Zed + Settings and Keymap;
- Zsh + Oh My Zsh (robbyrussell theme);
- PNPM, Node.js (LTS) and TypeScript;
- WhiteSur Dark Theme, Icons and SF Pro Fonts;
- Custom KDE global shortcuts (see below);

## ⌨️ Custom Shortcuts

| Shortcut | Action |
| --- | --- |
| `Meta` | Opens KRunner |
| `Meta` + `Tab` | Overview (multiple windows) |
| `Alt` + `Tab` | Cycle through windows |
| `Meta` + `Down` | Minimize the active window |
| `Meta` + `Up` | Restore the last minimized window, or maximize/unmaximize the active window if none is pending |

The `Meta+Up`/`Meta+Down` behavior is implemented with a custom KWin script (`config/kwin/metaupdownrestore`), since it isn't native KWin behavior.

## 🔥 After a fresh installation of Fedora KDE, open Konsole and run

sudo dnf install git -y && git clone https://github.com/marlonseben1/fedora-setup.git && cd fedora-setup && chmod +x install.sh && ./install.sh
