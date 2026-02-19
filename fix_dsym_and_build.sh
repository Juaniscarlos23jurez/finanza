#!/bin/bash
# Script para solucionar problema de dSYMs y generar archivo válido para App Store

set -e  # Salir si hay error

echo "🔧 Solucionando problemas de dSYMs y generando build limpio..."
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_DIR="/Users/juan/Desktop/finanzas/nutricion"

cd "$PROJECT_DIR"

# Paso 1: Cerrar Xcode
echo "1️⃣ Cerrando Xcode..."
killall Xcode 2>/dev/null && sleep 3 || echo "   Xcode no estaba abierto"

# Paso 2: Limpiar todo
echo "2️⃣ Limpiando archivos antiguos..."
flutter clean
rm -rf ios/build
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo -e "${GREEN}   ✅ Limpieza completa${NC}"

# Paso 3: Reinstalar pods con la nueva configuración
echo "3️⃣ Reinstalando CocoaPods con configuración de dSYMs..."
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
echo -e "${GREEN}   ✅ Pods instalados${NC}"

# Paso 4: Obtener dependencias
echo "4️⃣ Obteniendo dependencias de Flutter..."
flutter pub get
echo -e "${GREEN}   ✅ Dependencias obtenidas${NC}"

# Paso 5: Abrir Xcode
echo "5️⃣ Abriendo Xcode..."
open ios/Runner.xcworkspace

echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE - Pasos en Xcode:${NC}"
echo ""
echo "  📱 1. Selecciona 'Any iOS Device (arm64)' como destino"
echo "  🧹 2. Product → Clean Build Folder (⇧⌘K)"
echo "  📦 3. Product → Archive"
echo ""
echo "  ⚙️  4. En Organizer, verifica:"
echo "     • Build Settings → Debug Information Format = 'DWARF with dSYM File'"
echo "     • Build Settings → Strip Style = 'Non-Global Symbols'"
echo ""
echo "  📤 5. Distribute App → App Store Connect"
echo "     • Selecciona 'Upload'"
echo "     • Marca 'Include bitcode for iOS content' (si está disponible)"
echo "     • Marca 'Upload your app's symbols'"
echo ""
echo -e "${GREEN}✅ Script completado. Sigue los pasos en Xcode.${NC}"
echo ""
