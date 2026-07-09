#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

generation=""
dry_run="false"
keep_mounted="false"

usage() {
  cat <<'USAGE'
Usage: ./scripts/install.sh --generation <1|2> [--dry-run] [--keep-mounted]

Options:
  --generation, -g  Device generation to install: 1 or 2.
  --dry-run         Print the selected installer image without mounting it.
  --keep-mounted    Leave the DMG mounted after opening/running the installer.
  --help, -h        Show this help.
USAGE
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --generation|-g)
      generation="${2:-}"
      shift 2
      ;;
    --dry-run)
      dry_run="true"
      shift
      ;;
    --keep-mounted)
      keep_mounted="true"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
done

[[ "$generation" == "1" || "$generation" == "2" ]] || fail "Use --generation 1 or --generation 2."

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "This installer can only run on macOS."
fi

need_command sw_vers
need_command hdiutil

macos_version="$(sw_vers -productVersion)"
macos_major="$(printf '%s\n' "$macos_version" | awk -F. '{print $1}')"
macos_minor="$(printf '%s\n' "$macos_version" | awk -F. '{print $2}')"

select_dmg() {
  if [[ "$generation" == "2" ]]; then
    printf '%s\n' "$ROOT_DIR/MT7612_7610U_D5.0.1.25_SDK1.0.2.18_UI5.0.0.27_20151209.dmg"
    return
  fi

  case "$macos_minor" in
    7|8|9)
      printf '%s\n' "$ROOT_DIR/10.7.X-10.9.X(1st Gen)Resources/RTUSB_D2870-4.2.9.10_UI-5.0.0.01.dmg"
      ;;
    10)
      printf '%s\n' "$ROOT_DIR/10.10.X(1st Gen)Resources/360WiFI-148F-7601-760B-RT2870-MT7610U_D5.0.1.22_SDK1.0.2.14_UI5.0.0.21_20141224.dmg"
      ;;
    11)
      printf '%s\n' "$ROOT_DIR/10.11.X(1st Gen)Resources/BearExtender 5.4 (El Capitan Ready for chipsets RT2870 or RT3070).dmg"
      ;;
    *)
      printf '%s\n' "$ROOT_DIR/10.11.X(1st Gen)Resources/BearExtender 5.4 (El Capitan Ready for chipsets RT2870 or RT3070).dmg"
      ;;
  esac
}

dmg_path="$(select_dmg)"
[[ -f "$dmg_path" ]] || fail "Installer image not found: $dmg_path"

printf 'macOS: %s\n' "$macos_version"
printf 'Device generation: %s\n' "$generation"
printf 'Selected image: %s\n' "$dmg_path"

if [[ "$macos_major" -gt 10 || "$macos_minor" -gt 11 ]]; then
  printf 'Warning: these are legacy kext drivers. macOS %s may block installation or loading.\n' "$macos_version"
fi

if [[ "$dry_run" == "true" ]]; then
  exit 0
fi

mount_output="$(hdiutil attach -readonly -nobrowse "$dmg_path")"
mount_point="$(printf '%s\n' "$mount_output" | awk '/\/Volumes\// {sub(/^.*\/Volumes\//, "/Volumes/"); print; exit}')"

[[ -n "$mount_point" && -d "$mount_point" ]] || fail "Could not determine DMG mount point."
printf 'Mounted at: %s\n' "$mount_point"

should_detach="false"
detach() {
  if [[ "$should_detach" == "true" && "$keep_mounted" != "true" ]]; then
    hdiutil detach "$mount_point" >/dev/null || true
  fi
}
trap detach EXIT

pkg_path="$(find "$mount_point" -maxdepth 4 \( -name '*.pkg' -o -name '*.mpkg' \) -print -quit)"
app_path="$(find "$mount_point" -maxdepth 4 -name '*.app' -print -quit)"

if [[ -n "$pkg_path" ]]; then
  printf 'Running package installer: %s\n' "$pkg_path"
  should_detach="true"
  sudo installer -pkg "$pkg_path" -target /
elif [[ -n "$app_path" ]]; then
  printf 'Opening installer app: %s\n' "$app_path"
  open "$app_path"
  printf 'The installer app was opened. Follow the on-screen prompts, then eject %s from Finder.\n' "$mount_point"
else
  printf 'No package or app installer was found. Opening mounted image in Finder.\n'
  open "$mount_point"
  printf 'After installation, eject %s from Finder.\n' "$mount_point"
fi

if [[ "$keep_mounted" == "true" || "$should_detach" != "true" ]]; then
  printf 'Leaving image mounted at: %s\n' "$mount_point"
fi
