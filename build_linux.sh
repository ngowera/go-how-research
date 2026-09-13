#!/bin/bash
# =========================================================================
# GoHow Research - Linux Automated Build Script
# =========================================================================
set -e

echo ""
echo "========================================================================="
echo "   GoHow Research - Building for Linux Desktop (Ubuntu/Debian)"
echo "========================================================================="
echo ""

# 1. Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "[ERROR] 'flutter' command not found in your PATH."
    echo "Please ensure Flutter SDK is installed and exported to your PATH."
    echo "Example: export PATH=\"\$PATH:\$HOME/development/flutter/bin\""
    exit 1
fi

echo "[1/5] Enabling Linux desktop support..."
flutter config --enable-linux-desktop

echo "[2/5] Initialising Linux platform files..."
flutter create --platforms=linux .

echo "[3/5] Resolving Flutter package dependencies..."
flutter pub get

echo "[4/5] Generating Drift SQLite database schema code..."
dart run build_runner build --delete-conflicting-outputs

echo "[5/5] Building release Linux binary..."
flutter build linux --release

echo ""
echo "========================================================================="
echo "[SUCCESS] Linux build completed!"
echo "Output bundle directory:"
echo "  build/linux/x64/release/bundle/"
echo "Run application using:"
echo "  ./build/linux/x64/release/bundle/gohow_research"
echo "========================================================================="
