#!/bin/sh
# Install: download a GitHub release, extract, and copy to /usr/share/cockpit
# Uninstall: remove /usr/share/cockpit/jaspermate-io
# Usage: ./install.sh [version|latest]   or   ./install.sh uninstall
set -e

# GitHub repo (owner/repo). Public repo: jasper-node/jaspermate-io-cockpit-plugin. Override with GITHUB_REPO env if needed.
GITHUB_REPO="${GITHUB_REPO:-jasper-node/jaspermate-io-cockpit-plugin}"

case "${1:-}" in
  uninstall|--uninstall|-u)
    if [ -d /usr/share/cockpit/jaspermate-io ]; then
      echo "Uninstalling JasperMate IO plugin..."
      sudo rm -rf /usr/share/cockpit/jaspermate-io
      echo "Uninstalled."
    else
      echo "JasperMate IO plugin is not installed."
    fi
    exit 0
    ;;
esac

VERSION="${1:-latest}"
TMPDIR=""
cleanup() { [ -n "$TMPDIR" ] && [ -d "$TMPDIR" ] && rm -rf "$TMPDIR"; }
trap cleanup EXIT

if [ "$VERSION" = "latest" ]; then
  TAG="$(curl -sL "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
  [ -z "$TAG" ] && echo "Could not get latest release tag." && exit 1
  URL="https://github.com/$GITHUB_REPO/releases/download/$TAG/jaspermate-io-$TAG.tar.gz"
else
  TAG="$VERSION"
  URL="https://github.com/$GITHUB_REPO/releases/download/$TAG/jaspermate-io-$TAG.tar.gz"
fi

echo "Downloading $URL ..."
TMPDIR="$(mktemp -d)"
curl -sL "$URL" -o "$TMPDIR/pkg.tar.gz" || { echo "Download failed (check version exists)."; exit 1; }
tar -xzf "$TMPDIR/pkg.tar.gz" -C "$TMPDIR"
[ ! -d "$TMPDIR/jaspermate-io" ] && echo "Invalid package layout." && exit 1

if [ -d /usr/share/cockpit/jaspermate-io ]; then
  echo "Removing old installation..."
  sudo rm -rf /usr/share/cockpit/jaspermate-io
fi
sudo cp -r "$TMPDIR/jaspermate-io" /usr/share/cockpit/
echo "Installed to /usr/share/cockpit/jaspermate-io (release $TAG)"
