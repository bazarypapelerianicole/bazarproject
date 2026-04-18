#!/bin/bash
# ============================================================
# build_dmg.sh — Genera el instalador .dmg de BazarNicole
# Uso: ./scripts/build_dmg.sh
# ============================================================

set -e

APP_NAME="BazarNicole"
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
DMG_DIR="dist"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_PATH="${DMG_DIR}/${DMG_NAME}"

# ── 1. Compilar ──────────────────────────────────────────────
echo "▶ Compilando macOS release..."
flutter build macos --release

# Verificar que el .app existe
if [ ! -d "$APP_PATH" ]; then
  # Flutter puede usar minúsculas en el nombre de carpeta
  APP_PATH="build/macos/Build/Products/Release/bazarnicole.app"
  if [ ! -d "$APP_PATH" ]; then
    echo "❌ No se encontró el .app en build/macos/Build/Products/Release/"
    exit 1
  fi
fi

echo "✅ App encontrada: $APP_PATH"

# ── 2. Preparar carpeta dist ──────────────────────────────────
mkdir -p "$DMG_DIR"
rm -f "$DMG_PATH"

# ── 3. Convertir logo a .icns si no existe ────────────────────
ICNS_PATH="assets/image/icon.icns"
if [ ! -f "$ICNS_PATH" ] && [ -f "assets/image/logobazasr.png" ]; then
  echo "▶ Convirtiendo logo a .icns ..."
  ICONSET_DIR="assets/image/icon.iconset"
  mkdir -p "$ICONSET_DIR"
  for SIZE in 16 32 64 128 256 512; do
    sips -z $SIZE $SIZE "assets/image/logobazasr.png" \
      --out "${ICONSET_DIR}/icon_${SIZE}x${SIZE}.png" &>/dev/null
    sips -z $((SIZE*2)) $((SIZE*2)) "assets/image/logobazasr.png" \
      --out "${ICONSET_DIR}/icon_${SIZE}x${SIZE}@2x.png" &>/dev/null
  done
  iconutil -c icns "$ICONSET_DIR" -o "$ICNS_PATH"
  rm -rf "$ICONSET_DIR"
  echo "✅ Icono creado: $ICNS_PATH"
fi

# Argumento volicon opcional
VOLICON_ARG=()
if [ -f "$ICNS_PATH" ]; then
  VOLICON_ARG=(--volicon "$ICNS_PATH")
fi

# ── 4. Crear .dmg ─────────────────────────────────────────────
echo "▶ Creando $DMG_NAME ..."

create-dmg \
  --volname "${APP_NAME} ${VERSION}" \
  "${VOLICON_ARG[@]}" \
  --window-pos 200 120 \
  --window-size 660 400 \
  --icon-size 128 \
  --icon "${APP_NAME}.app" 160 185 \
  --hide-extension "${APP_NAME}.app" \
  --app-drop-link 500 185 \
  --no-internet-enable \
  "$DMG_PATH" \
  "$APP_PATH"


echo ""
echo "✅ Instalador listo: ${DMG_PATH}"
echo "   Tamaño: $(du -sh "${DMG_PATH}" | cut -f1)"
