# JasperMate IO Cockpit Plugin

A [Cockpit](https://cockpit-project.org/) plugin for monitoring and controlling JasperMate IO cards. It shows digital and analog inputs/outputs in a card-based UI and talks to a local API for live data and control.

## Features

- **Digital Inputs (DI)** — Read-only status with ON/OFF and LED-style indicator
- **Digital Outputs (DO)** — ON/OFF control per channel
- **Analog Inputs (AI)** — 4–20 mA values with bar and raw mA display
- **Analog Outputs (AO)** — Set value via modal; supports **4–20 mA** and **0–10 V**; raw or normalized input
- **Card reboot** — Reboot button in each card header
- **Connection status** — Indicates when the backend TCP connection is up

## Requirements

- Cockpit (with plugin support)
- Backend API (e.g. jm-utils) listening on **127.0.0.1:9080** and serving the expected JSON (cards list, `tcpConnected`, and per-card `last` data: `di`, `do`, `ai`, `ao`, `aoType`, `error`, etc.)

## Install

Using the install script (downloads a release from GitHub, extracts, and copies to `/usr/share/cockpit/`):

```bash
# Latest release
curl -sL https://raw.githubusercontent.com/jasper-node/jaspermate-io-cockpit-plugin/main/install.sh | sudo sh

# Specific version (e.g. v1.0.0)
curl -sL https://raw.githubusercontent.com/jasper-node/jaspermate-io-cockpit-plugin/main/install.sh | sudo sh -s -- v1.0.0
```

The script removes any existing installation before copying the new files. Reload Cockpit or restart `cockpit-ws` if needed.

## Uninstall

```bash
./install.sh uninstall
```

Or: `./install.sh --uninstall` / `./install.sh -u`. Removes `/usr/share/cockpit/jaspermate-io`.

## Manual installation

Alternatively, clone or copy this repo into a Cockpit plugin directory (e.g. under `/usr/share/cockpit/` or your distro’s cockpit package path). Ensure the plugin directory name is `jaspermate-io` and that `manifest.json` is at the package root. Example layout:

```
/usr/share/cockpit/jaspermate-io/
  manifest.json
  index.html
  jaspermate-io.js
  jaspermate-io.css
```

`manifest.json` registers the tool and points Cockpit to `index.html`.

## Usage

1. Log into Cockpit and open **JasperMate IO** from the sidebar/tools.
2. The page loads cards from the API. If no cards appear, ensure jm-utils (or your backend) is running and has detected IO cards.
3. Use **ON/OFF** on DO channels and **SET** on AO channels (opens the analog output modal). Use the **↻** button in a card header to reboot that card.

## Project structure

| Path | Description |
|------|-------------|
| `src/manifest.json` | Cockpit plugin manifest (name, title, tool entry) |
| `src/index.html` | Main page; loads Cockpit base CSS/JS and plugin assets |
| `src/jaspermate-io.js` | UI logic, API calls (127.0.0.1:9080), card render/update, DO/AO controls, AO modal |
| `src/jaspermate-io.css` | Styles for cards, sections, buttons, modal, loading state |

## API expectations

The plugin expects the backend at `127.0.0.1:9080` to provide JSON such as:

- `cards`: array of card objects with `id`, `module`, `last` (and optionally `last.serialNumber`).
- `tcpConnected`: boolean for connection status.
- Each `last` object can include:
  - `di`, `do`: arrays of booleans (DI read-only, DO current state).
  - `ai`, `ao`: arrays of numbers (e.g. AI/AO in raw units; AI as mA×1000).
  - `aoType`: optional array, e.g. `"4-20mA"` or `"0-10V"` per AO channel.
  - `error`: optional string shown on the card.

The same backend is expected to accept requests to set DO/AO and to reboot a card (exact endpoints are defined in `jaspermate-io.js`).

## License

See repository or project license file.
