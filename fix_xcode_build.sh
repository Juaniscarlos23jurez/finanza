#!/bin/bash
# Script para arreglar problemas de build de Xcode

echo "🔧 Solucionando problemas de Xcode..."

# Paso 1: Cerrar Xcode si está abierto
echo "1️⃣ Cerrando Xcode..."
killall Xcode 2>/dev/null || echo "   Xcode no estaba abierto"
sleep 2

# Paso 2: Limpiar Flutter
echo "2️⃣ Limpiando Flutter..."
cd /Users/juan/Desktop/finanzas/nutricion
flutter clean

# Paso 3: Limpiar DerivedData de Xcode
echo "3️⃣ Limpiando DerivedData de Xcode..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "   ✅ DerivedData limpiado"

# Paso 4: Limpiar build folder de iOS
echo "4️⃣ Limpiando build folder de iOS..."
rm -rf ios/build
rm -rf build
echo "   ✅ Build folders eliminados"

# Paso 5: Reinstalar pods
echo "5️⃣ Reinstalando pods..."
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..

# Paso 6: Obtener dependencias de Flutter
echo "6️⃣ Obteniendo dependencias de Flutter..."
flutter pub get

echo ""
echo "✅ ¡Listo! Ahora puedes:"
echo "   1. Abrir el workspace: open ios/Runner.xcworkspace"
echo "   2. En Xcode: Product → Clean Build Folder (Cmd+Shift+K)"
echo "   3. Luego: Product → Build (Cmd+B)"
echo ""
