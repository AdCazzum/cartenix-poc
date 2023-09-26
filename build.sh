#!/usr/bin/env sh

TMP_DIR="$(mktemp -d)"
TMP_STORE="$TMP_DIR/nix/store"

PACKAGE_NAME="$1"
NIXPKGS_REV="25be61c66ea9b55d1b6da87f9a0a08175d0d7692"
NIXPKGS="github:NixOS/nixpkgs/$NIXPKGS_REV"

nix copy --derivation "$NIXPKGS#$PACKAGE_NAME" \
    --to "$TMP_DIR" \
    --eval-store auto \
    --no-check-sigs

nix copy "$NIXPKGS#$PACKAGE_NAME" \
    --to "$TMP_DIR" \
    --eval-store auto \
    --no-check-sigs

PACKAGE_OUT="$(nix path-info "$NIXPKGS#$PACKAGE_NAME")"
PACKAGE_DRV="$(nix path-info --derivation "$NIXPKGS#$PACKAGE_NAME")"

nix build --store "$TMP_DIR" "$PACKAGE_DRV^*" --eval-store auto

find $TMP_STORE -name "*.drv" | sed -e "s|^$TMP_DIR||" -e "s/$/\^*/" | nix build --store "$TMP_DIR" --stdin --eval-store auto


nix store delete --store "$TMP_DIR" $PACKAGE_OUT --ignore-liveness

nix build --store "$TMP_DIR" "$NIXPKGS#$PACKAGE_NAME" -L --eval-store auto --offline --no-substitute
