#!/bin/zsh
# Build Moonlight from this checkout and replace the installed app in place.
#
# Hosts, pairings and settings live outside the bundle and are never touched:
#   ~/Library/Application Support/Moonlight/     Core Data host and app database
#   ~/Library/Preferences/std.skyhua.MoonlightMac.plist   settings
#
# Usage: ./update-in-place.sh [--build-only]
# Env:   MOONLIGHT_INSTALL_PATH   bundle to replace (default /Applications/Moonlight.app)
#        MOONLIGHT_SIGN_IDENTITY  codesign identity (default "-", ad-hoc)
set -euo pipefail

root="${0:A:h}"
cd "$root"

build_only=0
for arg in "$@"; do
  case "$arg" in
    --build-only) build_only=1 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

install_path="${MOONLIGHT_INSTALL_PATH:-/Applications/Moonlight.app}"
sign_identity="${MOONLIGHT_SIGN_IDENTITY:--}"
scheme="Moonlight for macOS"
derived="$root/build"
app="$derived/Build/Products/Release/Moonlight.app"
log="$derived/update-in-place.log"

step() { print -P "%F{cyan}==> $1%f"; }
fail() { print -P "%F{red}ERROR: $1%f" >&2; exit 1; }

command -v xcodebuild >/dev/null 2>&1 || fail "xcodebuild not found. Install Xcode, then: sudo xcode-select -s /Applications/Xcode.app"

# Same prebuilt frameworks CI downloads.
if [[ ! -d xcframeworks/FFmpeg.xcframework || ! -d xcframeworks/Opus.xcframework || ! -d xcframeworks/SDL2.xcframework ]]; then
  step "Downloading xcframeworks"
  mkdir -p xcframeworks
  curl -fL -o xcframeworks.zip "https://github.com/coofdy/moonlight-mobile-deps/releases/download/latest/moonlight-apple-xcframeworks.zip"
  unzip -oq xcframeworks.zip -d xcframeworks/
  rm -f xcframeworks.zip
fi

mkdir -p "$derived"
step "Building \"$scheme\" (Release), log: $log"
if ! xcodebuild -project Moonlight.xcodeproj -scheme "$scheme" -configuration Release \
    -derivedDataPath "$derived" -destination 'platform=macOS' ONLY_ACTIVE_ARCH=YES \
    CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
    BUILD_NUMBER="$(git rev-list --count HEAD 2>/dev/null || echo 0)" \
    build >"$log" 2>&1; then
  grep -E 'error:' "$log" | head -n 20 >&2 || true
  fail "Build failed. Full log: $log"
fi
[[ -d "$app" ]] || fail "Built app not found at $app"

step "Signing with identity \"$sign_identity\""
codesign --force --deep --sign "$sign_identity" "$app"

if (( build_only )); then
  echo "Built: $app"
  exit 0
fi

step "Quitting Moonlight"
osascript -e 'tell application "Moonlight" to quit' >/dev/null 2>&1 || true
for _ in {1..20}; do
  pgrep -x Moonlight >/dev/null 2>&1 || break
  sleep 0.5
done
pgrep -x Moonlight >/dev/null 2>&1 && pkill -x Moonlight || true

parent="${install_path:h}"
run=()
if [[ ! -w "$parent" || ( -e "$install_path" && ! -w "$install_path" ) ]]; then
  run=(sudo)
  step "Replacing $install_path (needs sudo)"
else
  step "Replacing $install_path"
fi

backup=""
if [[ -e "$install_path" ]]; then
  backup="${install_path%.app}.previous-$(date +%Y%m%d%H%M%S).app"
  "${run[@]}" mv "$install_path" "$backup"
fi
if "${run[@]}" ditto "$app" "$install_path"; then
  [[ -n "$backup" ]] && "${run[@]}" rm -rf "$backup"
else
  [[ -n "$backup" ]] && "${run[@]}" mv "$backup" "$install_path"
  fail "Could not copy the new app into place; the previous version was restored"
fi
"${run[@]}" xattr -dr com.apple.quarantine "$install_path" 2>/dev/null || true

step "Launching"
open "$install_path"
echo "Done. Hosts and settings were left untouched in ~/Library/Application Support/Moonlight and ~/Library/Preferences."
