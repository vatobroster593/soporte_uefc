@echo off
echo Limpiando proyecto Flutter...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM dart.exe 2>nul
timeout /t 2 >nul
rd /s /q build 2>nul
flutter clean
flutter pub get
echo Listo! Ahora puedes ejecutar la app
pause