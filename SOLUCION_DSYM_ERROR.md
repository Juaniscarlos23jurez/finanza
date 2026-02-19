# 🔧 Solución a Errores de Upload a App Store

## 📋 Problemas Encontrados

### 1. Invalid Package / Corrupt Archive
```
Invalid package. The uploaded package is corrupt.
```

### 2. Missing dSYM Symbols
```
The archive did not include a dSYM for the objective_c.framework 
with the UUIDs [0DC8915E-2E2A-3A7D-B620-90DB9DB40DEA]
```

---

## 🎯 Causas del Problema

### dSYMs (Debug Symbols)
- **Qué son**: Archivos que contienen información de debug para crash reports
- **Por qué faltan**: CocoaPods a veces no genera dSYMs automáticamente para frameworks
- **Por qué App Store los necesita**: Para simbolizar crash reports en App Store Connect

### Paquete Corrupto
Puede ser causado por:
- ❌ dSYMs faltantes (principal causa)
- ❌ Archive incompleto
- ❌ Error durante el upload
- ❌ Build settings incorrectos

---

## ✅ SOLUCIÓN IMPLEMENTADA

### Cambio 1: Podfile Actualizado
**Archivo**: `/ios/Podfile`

**Agregado al `post_install` block**:
```ruby
# Forzar generación de dSYMs para todos los frameworks
config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'

# Configuración para evitar strip de símbolos necesarios
if config.name == 'Release' || config.name == 'Profile'
  config.build_settings['STRIP_STYLE'] = 'non-global'
  config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'YES'
  config.build_settings['COPY_PHASE_STRIP'] = 'NO'
end
```

**¿Qué hace esto?**
- ✅ Fuerza que TODOS los frameworks generen dSYMs
- ✅ Configura el strip style para preservar símbolos globales
- ✅ Asegura que el formato de debug sea correcto

---

## 🚀 PASOS PARA GENERAR BUILD CORRECTO

### Opción A: Usar el Script Automático (RECOMENDADO)

```bash
cd /Users/juan/Desktop/finanzas/nutricion
chmod +x fix_dsym_and_build.sh
./fix_dsym_and_build.sh
```

Luego sigue las instrucciones que muestra el script.

---

### Opción B: Pasos Manuales

#### 1. Limpiar Todo
```bash
cd /Users/juan/Desktop/finanzas/nutricion
flutter clean
rm -rf ios/build build
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

#### 2. Reinstalar Pods
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

#### 3. Obtener Dependencias
```bash
flutter pub get
```

#### 4. Abrir Xcode
```bash
open ios/Runner.xcworkspace
```

#### 5. En Xcode - Verificar Build Settings

**Para el target "Runner"**:
1. Selecciona el proyecto "Runner" en el navegador
2. Selecciona el target "Runner"
3. Ve a "Build Settings"
4. **Busca y verifica**:

| Setting | Valor Correcto |
|---------|---------------|
| Debug Information Format | **DWARF with dSYM File** |
| Strip Style | **Non-Global Symbols** |
| Strip Installed Product | **Yes** (solo Release) |
| Only Active Architecture | **No** (para Release) |

#### 6. Limpiar Build Folder
- **Product → Clean Build Folder** (⇧⌘K)

#### 7. Seleccionar Device
- En el selector de destino: **Any iOS Device (arm64)**
- NO uses el simulador

#### 8. Archive
- **Product → Archive**
- Espera a que complete (puede tomar 5-10 minutos)

#### 9. Verificar dSYMs en el Archive

Antes de distribuir, verifica:
```bash
# En terminal, después del archive
cd ~/Library/Developer/Xcode/Archives

# Busca el archive más reciente
find . -name "*.xcarchive" -type d -maxdepth 2 | sort | tail -1

# Verifica que tenga dSYMs
ls -la "RUTA_DEL_ARCHIVE/dSYMs/"
```

Deberías ver archivos `.dSYM` para todos los frameworks, incluyendo `objective_c.framework.dSYM`.

#### 10. Distribuir a App Store

En el Organizer:
1. Selecciona el archive
2. Click en **Distribute App**
3. Selecciona **App Store Connect**
4. **Upload**
5. **IMPORTANTE**: Marca estas opciones:
   - ✅ **Upload your app's symbols to receive symbolicated reports** ⭐
   - ✅ Include bitcode (si está disponible)
   - ✅ Strip Swift symbols (opcional)

6. Click **Upload**
7. Espera confirmación (puede tardar 10-20 minutos)

---

## 🔍 Verificación Post-Upload

Después del upload exitoso:

### En App Store Connect:
1. Ve a tu app
2. **TestFlight** → Builds
3. Espera que aparezca el build (10-30 min)
4. Verifica que diga **"Processing"** y luego **"Ready to Submit"**
5. **NO debería decir** "Missing Compliance" o "Invalid Binary"

### Verificar Símbolos:
1. Ve a **App Store Connect**
2. **TestFlight** → Tu build
3. Sección **Build Metadata**
4. Verifica que **"Includes Symbols"** = **Yes** ✅

---

## ❌ Si Sigue Fallando

### Error: "Package is corrupt"
**Posibles causas adicionales**:
1. **Problema de red durante upload**
   - Solución: Reintenta el upload desde Organizer
   
2. **Versión de Xcode desactualizada**
   - Verifica que estés usando Xcode 14+ 
   - Actualiza si es necesario

3. **Tamaño del archivo muy grande**
   - Si tu .ipa es >200MB, puede fallar
   - Considera reducir assets si es posible

### Error: "Still missing dSYM"
Si TODAVÍA falta el dSYM de `objective_c.framework`:

```bash
# Verifica la versión del pod objective_c
cd ios
pod list | grep objective_c

# Actualiza a la última versión
pod update objective_c
pod install

# Luego vuelve a hacer archive
```

---

## 📝 Notas Importantes

### ⚠️ SIEMPRE Usa .xcworkspace
```bash
# ✅ CORRECTO
open ios/Runner.xcworkspace

# ❌ INCORRECTO
open ios/Runner.xcodeproj
```

### ⚠️ Device Target
- **Archive SOLO funciona con "Any iOS Device"**
- NO uses el simulador para archives

### ⚠️ Certificados y Provisioning
- Asegúrate de tener certificados válidos
- Verifica que el provisioning profile esté actualizado

---

## 🎯 Resumen de Cambios

### Archivos Modificados:
1. ✅ `ios/Podfile` - Configuración de dSYMs
2. ✅ `ios/Runner/Info.plist` - REVERSED_CLIENT_ID corregido (cambio anterior)
3. ✅ `lib/services/auth_service.dart` - Import corregido (cambio anterior)
4. ✅ `lib/screens/login_screen.dart` - Google Sign-In mejorado (cambio anterior)

### Scripts Creados:
1. ✅ `fix_dsym_and_build.sh` - Script completo para solucionar y rebuild

---

## 🚀 Próximos Pasos

1. **Ejecuta el script**:
   ```bash
   cd /Users/juan/Desktop/finanzas/nutricion
   chmod +x fix_dsym_and_build.sh
   ./fix_dsym_and_build.sh
   ```

2. **Sigue las instrucciones** que muestra el script

3. **Haz Archive** en Xcode

4. **Sube a App Store** con símbolos marcados

5. **Espera** el procesamiento en App Store Connect

6. **Verifica** que el build aparezca sin errores

---

## ✨ Todo Debería Funcionar Ahora

Con estos cambios:
- ✅ Los dSYMs se generarán automáticamente
- ✅ El archivo no estará corrupto
- ✅ App Store Connect aceptará el upload
- ✅ Los crash reports serán simbolizados

**¿Siguiente error?** Házmelo saber y lo solucionamos! 🚀
