#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

section() {
  printf '\n== %s ==\n' "$1"
}

print_command_status() {
  if command -v "$1" >/dev/null 2>&1; then
    printf '%s: found\n' "$1"
  else
    printf '%s: missing\n' "$1"
  fi
}

section "System"
if [[ "$(uname -s)" == "Darwin" ]]; then
  printf 'macOS: %s\n' "$(sw_vers -productVersion)"
  printf 'Build: %s\n' "$(sw_vers -buildVersion)"
  printf 'Architecture: %s\n' "$(uname -m)"
else
  printf 'Not running on macOS: %s\n' "$(uname -s)"
fi

section "Required Tools"
print_command_status hdiutil
print_command_status installer
print_command_status system_profiler
print_command_status csrutil

section "System Integrity Protection"
if command -v csrutil >/dev/null 2>&1; then
  csrutil status || true
else
  printf 'csrutil is only available on supported macOS versions.\n'
fi

section "Bundled Installer Images"
find "$ROOT_DIR" -maxdepth 3 -type f -name '*.dmg' -print | sort

section "Installed Legacy Drivers"
if command -v kmutil >/dev/null 2>&1; then
  kmutil showloaded 2>/dev/null | grep -Ei 'ralink|mediatek|rt2870|mt76' || printf 'No matching loaded kexts found via kmutil.\n'
elif command -v kextstat >/dev/null 2>&1; then
  kextstat 2>/dev/null | grep -Ei 'ralink|mediatek|rt2870|mt76' || printf 'No matching loaded kexts found via kextstat.\n'
else
  printf 'No kext inspection command found.\n'
fi

section "USB Wi-Fi Candidates"
if command -v system_profiler >/dev/null 2>&1; then
  system_profiler SPUSBDataType | grep -Ei '360|ralink|mediatek|802.11|wireless|wifi|wi-fi|rt2870|mt76' || \
    printf 'No obvious USB Wi-Fi adapter found in system_profiler output.\n'
else
  printf 'system_profiler is not available.\n'
fi

section "Next Step"
printf 'Run ./scripts/install.sh --generation 1 or ./scripts/install.sh --generation 2.\n'
