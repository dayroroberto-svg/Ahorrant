@echo off
title Ahorrant - Aplicacion Financiera Gamificada

echo.
echo ==========================================
echo   Ahorrant - Aplicacion de Finanzas Personales
echo ==========================================
echo.

REM Detectar comando flutter
set FLUTTER_CMD=flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    if exist "C:\Users\%USERNAME%\develops\flutter_windows_3.47.9-stable\flutter\bin\flutter.bat" (
        set "FLUTTER_CMD=C:\Users\%USERNAME%\develops\flutter_windows_3.47.9-stable\flutter\bin\flutter.bat"
    ) else (
        echo ERROR: No se encontro Flutter en el PATH ni en la ruta por defecto.
        echo Asegurate de que Flutter este instalado y agregado al PATH del sistema.
        pause
        exit /b 1
    )
)

echo [1/3] Verificando dispositivos conectados...
call %FLUTTER_CMD% devices

echo.
echo [2/3] Verificando dependencias...
call %FLUTTER_CMD% pub get

echo.
echo [3/3] Iniciando Ahorrant...
echo.
call %FLUTTER_CMD% run

echo.
echo ==========================================
echo   Ahorrant finalizado
echo ==========================================
