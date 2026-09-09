@echo off
title Instalador Bazar y Papelería v2.0.0
echo Iniciando instalador profesional...
echo.
ECHO est� desactivado.
:: Verificar que PowerShell esté disponible
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell no está disponible en este sistema
    echo Este instalador requiere PowerShell para funcionar
    pause
    exit /b 1
)
ECHO est� desactivado.
:: Cambiar a la política de ejecución temporal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalador_profesional.ps1"
ECHO est� desactivado.
:: Verificar si hubo errores
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Hubo un problema durante la instalación.
    echo Verifique que tiene permisos suficientes.
    pause
)
