#!/bin/sh
# Download a GitHub release tarball, extract, and copy to /usr/share/cockpit
set -e

# GitHub repo (owner/repo). Override with GITHUB_REPO env if needed.
GITHUB_REPO="${GITHUB_REPO:-}"
if [ -z "$GITHUB_REPO" ] && command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  origin="$(git remote get-url origin 2>/dev/null || true)"
  case "$origin" in
    https://github.com/*.git) GITHUB_REPO="${origin#https://github.com/}"; GITHUB_REPO="${GITHUB_REPO%.git}" ;;
    git@github.com:*.git)     GITHUB_REPO="${origin#git@github.com:}"; GITHUB_REPO="${GITHUB_REPO%.git}" ;;
  esac
fi
if [ -z "$GITHUB_REPO" ]; then
  echo "Set GITHUB_REPO (e.g. owner/jaspermate-io-cockpit-plugin) or run from a git clone."
  exit 1
fi

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

sudo cp -r "$TMPDIR/jaspermate-io" /usr/share/cockpit/
echo "Installed to /usr/share/cockpit/jaspermate-io (release $TAG)"
