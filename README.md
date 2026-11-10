# Ahorrant - Proyecto Flutter

## Requisitos previos

1. **Flutter SDK**: Versión 3.10 o superior
   - Descargar desde: https://flutter.dev/docs/get-started/install
   - Ejecutar: `flutter doctor` para verificar instalación

2. **Android Studio**: Para emulador y herramientas Android
   - SDK de Android 31 (API 31) recomendado
   - Componentes: Android SDK Platform-Tools, Build Tools

3. **Dispositivo**: Android físico o emulador con:
   - Android 8.0 (API 26) o superior
   - Permisos de notificaciones activables

## Instalación y ejecución

### Opción 1: Desarrollo con dispositivo real

1. Clonar repositorio o copiar archivos del proyecto
2. Abrir terminal en la carpeta del proyecto (`C:\WEB\Ahorrant`)
3. Ejecutar:
   ```batch
   flutter doctor
   ```
   - Esto verificará tu entorno e instalará dependencias faltantes

4. Conectar dispositivo Android vía USB
   - Enable "Depuración USB" en el teléfono
   - Aceptar permisos de autorización en el dispositivo

5. Ejecutar la aplicación:
   ```batch
   flutter run
   ```

### Opción 2: Usando emulador Android

1. Crear emulator en Android Studio
2. Iniciar el emulador
3. Ejecutar:
   ```batch
   flutter devices
   ```
   - Debería listar el emulador disponible

4. Ejecutar:
   ```batch
   flutter run
   ```

### Opción 3: Script de inicio rápido (Windows)

Si Flutter está en `C:\REA\dist\application\flutter\`:

```batch
@echo off
set FLUTTER_PATH=C:\REA\dist\application\flutter
%FLUTTER_PATH%\bin\flutter doctor
echo.
echo ¿Conectado dispositivo Android? Presiona cualquier tecla para continuar...
pause >nul
%FLUTTER_PATH%\bin\flutter run
```

## Estructura del proyecto

```
lib/
├── main.dart          # Punto de entrada
├── screens/           # 6 módulos de la app
│   ├── inicio_screen.dart
│   ├── hormiguero_screen.dart
│   ├── armario_screen.dart
│   ├── metas_screen.dart
│   ├── clases_screen.dart
│   └── progreso_screen.dart
├── services/          # Lógica y servicios
│   └── notification_service.dart
└── widgets/           # Componentes reutilizables
```

## Configuración Android necesaria

1. **AndroidManifest.xml** requiere:
   - `USE_FULL_SCREEN_INTENT` para notificaciones
   - Permiso `FOREGROUND_SERVICE` 
   - Servicio `NotificationListenerService`

2. **AndroidManifest.kt** (servicio nativo):
   ```kotlin
   <service
       android:name=".notification.NotificationService"
       android:exported="false"
       android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE">
       <intent-filter>
           <action android:name="android.service.notification.NotificationListenerService" />
       </intent-filter>
   </service>
   ```

3. **Configuración de usuario**:
   - Al iniciar la app, se solicitará permiso de notificaciones
   - El usuario debe aceptar en el diálogo de Android
   - Luego ir a Configuración > Aplicaciones > Ahorrant > Notificaciones > Permitir

## Funcionalidades MVP (4 días)

- [x] Apertura directa sin registro
- [x] Solicitud permisos notificaciones
- [x] Detección Yape desde notificaciones
- [x] Clasificación de movimientos
- [x] Panel financiero resumen
- [x] Mascota virtual 4 estados
- [x] Sistema Hormigasoles básico
- [x] Metas individuales
- [x] SQLite local + sincronización Supabase
- [x] 6 pestañas navegación bottom

## Limitaciones conocidas

- Requiere Android (iOS no soporta lectura de notificaciones ajenas)
- Solo detecta Yape cuando las notificaciones incluyen monto formateado S/ XX.XX
- Almacenamiento local SQLite es la fuente de verdad; Supabase sincroniza cuando hay internet
- Sin registro de usuario: identidad anónima por instalación
- Los Hormigasoles son recompensas virtuales, no dinero real

## Validación con usuario real

1. Tener a un usuario universitario probar la app
2. Verificar que:
   - La app abre directamente sin login
   - Solicita permisos de notificaciones claros
   - Detecta movimientos Yape cuando el formato es compatible
   - Clasifica y registra el gasto correctamente
   - La mascota reacciona a las actividades
   - Se pueden comprar accesorios con Hormigasoles

## Comandos útiles

```batch
# Ver dispositivos conectados
flutter devices

# Reiniciar motor de Flutter
flutter clean

# Obtener dependencias
flutter pub get

# Compilar APK para release
flutter build apk --release

# Ver registro de tiempo de ejecución
flutter logs
```

## Soporte

Para issues con la detección de notificaciones Yape:
1. Verificar formato de notificación en dispositivo real
2. Revisar logs con `flutter logs`
3. Validar que el servicio NotificationListenerService esté activo
4. Probar con diferentes montos (S/ 1.00, S/ 10.00, S/ 100.00)