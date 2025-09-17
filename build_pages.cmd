@echo off
setlocal
REM Detecta nome do repo pela pasta atual, a menos que seja passado como argumento 1
if "%~1"=="" (
  for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Item .).BaseName"') do set REPO_NAME=%%i
) else (
  set REPO_NAME=%~1
)
echo [Accessa] Build Web para GitHub Pages com base-href "/%REPO_NAME%/"
where flutter >nul 2>&1 || (echo ERRO: Flutter nao encontrado no PATH. & exit /b 1)
flutter clean
flutter build web --release --base-href="/%REPO_NAME%/"
if errorlevel 1 (echo Build falhou. & exit /b 1)
copy /Y build\web\index.html build\web\404.html >nul
echo.
echo Pronto! Publique o conteudo de build\web no branch gh-pages, ou deixe o GitHub Actions fazer o deploy no push.
echo URL esperada: https://^<seu-usuario^>.github.io/%REPO_NAME%/
echo.
endlocal
