#!/bin/bash

# Script para abrir Xcode correctamente con el workspace de Flutter
# Uso: ./open-xcode.sh

echo "🧹 Limpiando caches de Xcode..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-* 2>/dev/null
rm -rf ios/build 2>/dev/null

echo "🔄 Asegurando que Flutter está actualizado..."
flutter pub get

echo "📦 Reinstalando pods..."
cd ios
rm -rf Pods Podfile.lock .symlinks 2>/dev/null
pod install
cd ..

echo "🚀 Abriendo Xcode con el workspace correcto..."
open ios/Runner.xcworkspace

echo "✅ Xcode abierto!"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   1. En Xcode, selecciona 'Runner' en el navegador de proyecto"
echo "   2. En Product > Scheme, asegúrate de que 'Runner' esté seleccionado"
echo "   3. En Product > Destination, selecciona un dispositivo o simulador"
echo "   4. Si ves 'No such module Flutter', presiona Cmd+Shift+K para limpiar"
echo "   5. Luego presiona Cmd+B para compilar"
