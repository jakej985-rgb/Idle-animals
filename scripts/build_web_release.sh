#!/usr/bin/env bash
# ==============================================================================
# Idle Animals - Production Web Release Build for M3tal-Hub
# Builds the Flutter Web bundle configured for deployment under /Idle-animals/
# ==============================================================================

set -euo pipefail

BASE_HREF="${1:-/Idle-animals/}"

# Ensure trailing slash on base href
[[ "$BASE_HREF" != */ ]] && BASE_HREF="${BASE_HREF}/"
# Ensure leading slash on base href
[[ "$BASE_HREF" != /* ]] && BASE_HREF="/${BASE_HREF}"

echo "===================================================="
echo "Building Idle Animals Web Release"
echo "Target Base Href: ${BASE_HREF}"
echo "===================================================="

# Check if flutter command is present
if ! command -v flutter &> /dev/null; then
  echo "Error: flutter command not found in PATH." >&2
  exit 1
fi

echo "--> Resolving Flutter dependencies..."
flutter pub get

echo "--> Compiling Web bundle..."
flutter build web --release --base-href "${BASE_HREF}"

# Verification
if [[ ! -f "build/web/index.html" ]]; then
  echo "Error: build/web/index.html was not generated!" >&2
  exit 1
fi

echo "--> Verifying base href injection in index.html..."
if grep -q "base href=\"${BASE_HREF}\"" "build/web/index.html" || grep -q "base href='${BASE_HREF}'" "build/web/index.html"; then
  echo "Base href verified successfully: ${BASE_HREF}"
else
  echo "Warning: Exact base href pattern not matched, checking base tag:"
  grep -i "<base" "build/web/index.html" || true
fi

echo "===================================================="
echo "Idle Animals Web build ready at: build/web"
echo "===================================================="
