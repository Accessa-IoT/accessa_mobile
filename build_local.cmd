@echo off
setlocal
echo [Accessa] Build Web (local) com base-href "/"
where flutter >nul 2>&1 || (echo ERRO: Flutter nao encontrado no PATH. & exit /b 1)
flutter clean
flutter build web --release --base-href="/"
if errorlevel 1 (echo Build falhou. & exit /b 1)
echo Abrindo http://localhost:8080/ ...
start "" http://localhost:8080/
where python >nul 2>&1 && (
  python -m http.server -d build\web 8080
) || (
  where py >nul 2>&1 && (
    py -m http.server -d build\web 8080
  ) || (
    echo ERRO: Python nao encontrado. Instale-o ou use: flutter run -d web-server --web-port 8080
    exit /b 1
  )
)
endlocal
