#!/usr/bin/env bash
set -euo pipefail

DMG_PATH="${1:?Usage: verify_dmg.sh path/to/ResolveMediaConverter.dmg}"

MOUNT_POINT=""
cleanup() {
  if [[ -n "${MOUNT_POINT}" ]]; then
    hdiutil detach "${MOUNT_POINT}" -quiet || true
  fi
}
trap cleanup EXIT

echo "== Verify DMG file integrity =="
hdiutil verify "${DMG_PATH}"

echo "== Mount DMG =="
ATTACH_OUT="$(hdiutil attach -nobrowse -readonly "${DMG_PATH}")"
MOUNT_POINT="$(echo "${ATTACH_OUT}" | sed -n 's#^.*\(/Volumes/.*\)$#\1#p' | head -n 1)"
if [[ -z "${MOUNT_POINT}" ]]; then
  echo "ERROR: Could not determine mounted DMG path from hdiutil output."
  echo "${ATTACH_OUT}"
  exit 1
fi
echo "Mounted at: ${MOUNT_POINT}"

APP="${MOUNT_POINT}/resolve_media_converter.app"
if [[ ! -d "${APP}" ]]; then
  APP="$(find "${MOUNT_POINT}" -maxdepth 1 -name '*.app' -type d -print -quit)"
fi
if [[ -z "${APP}" || ! -d "${APP}" ]]; then
  echo "ERROR: Could not find an app bundle in ${MOUNT_POINT}."
  ls -la "${MOUNT_POINT}" || true
  exit 1
fi

echo "== Check /Applications link exists =="
test -L "${MOUNT_POINT}/Applications" || test -e "${MOUNT_POINT}/Applications"

echo "== Validate Info.plist =="
plutil -lint "${APP}/Contents/Info.plist"
BID="$(defaults read "${APP}/Contents/Info" CFBundleIdentifier)"
EXE="$(defaults read "${APP}/Contents/Info" CFBundleExecutable)"
echo "CFBundleIdentifier=${BID}"
echo "CFBundleExecutable=${EXE}"

echo "== Check app icon resources exist =="
if ! ls "${APP}/Contents/Resources/"*.icns >/dev/null 2>&1 && [[ ! -f "${APP}/Contents/Resources/Assets.car" ]]; then
  echo "ERROR: No icon resources found in ${APP}/Contents/Resources (expected *.icns or Assets.car)."
  exit 1
fi

echo "== Optional smoke launch (5s) =="
BIN="${APP}/Contents/MacOS/${EXE}"
if [[ -x "${BIN}" ]]; then
  rm -f /tmp/resolve_media_converter_smoke.log /tmp/resolve_media_converter_smoke_pid || true
  ( "${BIN}" >/tmp/resolve_media_converter_smoke.log 2>&1 & echo $! > /tmp/resolve_media_converter_smoke_pid ) || true
  sleep 5
  kill "$(cat /tmp/resolve_media_converter_smoke_pid)" >/dev/null 2>&1 || true
  echo "--- smoke log (tail) ---"
  tail -n 120 /tmp/resolve_media_converter_smoke.log || true
fi

echo "DMG verification OK"
