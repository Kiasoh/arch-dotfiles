# Hardware drawer and authentication

`Power.qml` presents the drawer; `PowerState.qml` owns hardware reads and serialized actions. The button, card, segmented row, switch, and process reader in `components/` can be reused independently. `SegRow.labelFor` formats values; `chooseFn` handles selection.

The drawer creates its controls when opened and releases them after the closing animation finishes. Tab selection, saved gaps, reboot notices and active hardware actions survive closing and reopening.

`auth.qml` runs the standalone `PolkitPrompt.qml` through `scripts/qs-polkit-agent.py`. It uses the installed Python GObject/Polkit bindings and passes responses directly to PAM through private pipes. The requesting process's complete command comes from Polkit's caller PID; if that process cannot be read, the policy message is still shown.

The listener stays running while idle. The prompt is created when a request arrives, stays loaded during authentication and retries, and is released when the request closes.

The package's `.config/systemd/user/hyprpolkitagent.service.d/quickshell.conf` replaces the existing agent service's command. After installing the dotfiles, run `systemctl --user daemon-reload` and `systemctl --user restart hyprpolkitagent`. The existing Hyprland autostart still starts this service. To restore the original agent, remove this drop-in from `~/.config/systemd/user/hyprpolkitagent.service.d/`, reload systemd, and restart the service.

Run `python3 tests/test_power.py`, `python3 tests/test_polkit.py`, and `node tests/power-actions.mjs` to check the controls and action handling. QML UI checks use an active Wayland session by default; privileged commands and PAM responses are mocked. For offscreen lifecycle and interaction checks, run `QT_QPA_PLATFORM=offscreen python3 tests/test_power.py`; temporary test copies use floating windows in place of Wayland panels.
