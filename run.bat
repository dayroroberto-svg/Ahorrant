@echo off
title Ahorrant - Aplicación Financiera Gamificada

REM Configurar ruta de Flutter
set FLUTTER_PATH=C:\REA\dist\application\flutter

echo.
echo ==========================================
echo   Ahorrant - Aplicación de Finanzas Personales
echo ==========================================
echo.

REM Verificar si Flutter está en la ruta esperada
if not exist "%FLUTTER_PATH%\bin\flutter" (
    echo.
    error level 1
    echo ERROR: No se encontró Flutter en %FLUTTER_PATH%\bin\flutter
    echo.
    echo Por favor:
    echo   1. Instalar Flutter desde https://flutter.dev/docs/get-started/install
    echo   2. O ajustar la variable FLUTTER_PATH en este script
    echo.
    pause
    exit /b 1
)

REM Verificar conexión de dispositivos
echo.
echo [1/3] Verificando dispositivos conectados...
flutter devices >nul 2>&1
if %errorlevel% neq 0 (
    echo - No se detectaron dispositivos Flutter
    echo - Asegúrate de tener un dispositivo Android conectado via USB
    echo - O inicia un emulador de Android
    echo.
)

REM Ejecutar doctor primero para verificar entorno
echo.
echo [2/3] Ejecutando flutter doctor...
call %FLUTTER_PATH%\bin\flutter doctor --quiet 2>&1 | find "✓" | find /v "!" >nul
if %errorlevel% equ 0 (
    echo - Entorno básico OK
) else (
    echo - Algunas dependencias faltan, ejecuta manualmente: flutter doctor
)

REM Preguntar si quiere continuar a pesar de advertencias
echo.
echo ¿Continuar con flutter run? (s/n)
set /p respuesta=
if /i "%respuesta%" neq "s" (
    echo Cancelado.
    exit /b 0
)

REM Ejecutar la aplicación
echo.
echo [3/3] Iniciando Ahorrant...
echo.
echo Por favor, ten a mano tu dispositivo Android con:
echo - Depuración USB activada
echo - Permisos de notificaciones concedidos a la app
echo.
echo El primer uso solicitará permisos de notificaciones.
echo.
echo Presiona Ctrl+C para cancelar en los próximos 5 segundos...
timeout /t 5 >nul

echo.
echo Ejecutando: flutter run
echo.
%FLUTTER_PATH%\bin\flutter run

echo.
echo ==========================================
echo   Ahorrant finalizado
echo ==========================================