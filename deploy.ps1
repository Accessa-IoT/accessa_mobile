<#
.SYNOPSIS
  Builda o Flutter Web e faz deploy para a branch gh-pages via worktree (Windows).

.DESCRIPTION
  - Gera build com base-href correto (/REPO/) e SEM service worker (evita cache).
  - Cria/usa uma worktree em ..\_site para a branch de publicação (padrão: gh-pages).
  - Limpa tudo na worktree, preservando o arquivo .git, e copia a build.
  - Faz commit e push da gh-pages.
  - Cria 404.html (fallback SPA) e .nojekyll.

.PARAMETER Branch
  Branch de publicação (default: gh-pages).

.PARAMETER WorktreePath
  Caminho da worktree (default: ..\_site).

.PARAMETER RepoName
  Nome do repositório para compor o base-href. Se não informado, é inferido do remote origin.

.PARAMETER Owner
  Dono/organização do GitHub. Se não informado, é inferido do remote origin.

.PARAMETER SkipClean
  Se informado, não executa 'flutter clean'.

.EXAMPLE
  .\deploy.ps1
  # Builda e publica em gh-pages usando ..\_site, inferindo repo/owner do remote.

.EXAMPLE
  .\deploy.ps1 -Branch gh-pages -WorktreePath ..\_site -RepoName accessa_mobile -Owner Accessa-IoT

.NOTES
  Requisitos: git, flutter, PowerShell 5+.
#>

param(
  [string]$Branch = "gh-pages",
  [string]$WorktreePath = "..\_site",
  [string]$RepoName,
  [string]$Owner,
  [switch]$SkipClean
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Exec($cmd, $errmsg) {
  Write-Host "→ $cmd" -ForegroundColor Cyan
  $p = Start-Process -FilePath "powershell" -ArgumentList "-NoProfile","-Command",$cmd -Wait -PassThru -WindowStyle Hidden
  if ($p.ExitCode -ne 0) { throw $errmsg }
}

# 0) Checagem de repo
if (-not (Test-Path ".git")) {
  throw "Este script deve ser executado na RAIZ do repositório (onde existe a pasta .git)."
}

# 1) Detecta remote origin -> owner/repo
try {
  $remote = (git remote get-url origin).Trim()
} catch {
  throw "Não foi possível obter o remote 'origin'. Configure com: git remote add origin <url>"
}

# Extrai owner e repo do remote (HTTPS ou SSH)
# Ex.: https://github.com/Owner/Repo.git  ou  git@github.com:Owner/Repo.git
$rx = [regex] '(?:github\.com[:/])(?<owner>[^/]+)/(?<repo>[^/.]+)'
$m = $rx.Match($remote)
if ($m.Success) {
  if (-not $Owner) { $Owner = $m.Groups["owner"].Value }
  if (-not $RepoName) { $RepoName = $m.Groups["repo"].Value }
}

if (-not $RepoName) { $RepoName = Split-Path -Leaf (Get-Location) }
$BaseHref = "/$RepoName/"
$PagesUrl = if ($Owner) { "https://$Owner.github.io/$RepoName/" } else { "https://<Owner>.github.io/$RepoName/" }

Write-Host "Repo detectado: $Owner/$RepoName" -ForegroundColor Green
Write-Host "Base href: $BaseHref" -ForegroundColor Green
Write-Host ""

# 2) Build do Flutter Web
if (-not $SkipClean) {
  Exec "flutter clean" "Falha no flutter clean"
}
Exec "flutter build web --release --base-href `"$BaseHref`" --pwa-strategy=none" "Falha no flutter build web"

# Garante o base no index.html
$index = Get-Content "build\web\index.html" -Raw
if ($index -notmatch [regex]::Escape("<base href=""$BaseHref"">")) {
  throw "O index.html não contém <base href=""$BaseHref"">. Verifique --base-href."
}

# 3) Preparar/atualizar worktree
git worktree prune | Out-Null
$wtMeta = ".git\worktrees\" + (Split-Path -Leaf $WorktreePath).TrimStart(".\")
if (Test-Path $wtMeta -PathType Container -ErrorAction SilentlyContinue) {
  try { Remove-Item $wtMeta -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}

if (Test-Path $WorktreePath) {
  try { Remove-Item $WorktreePath -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}

# Cria worktree; se a branch remota existir, puxe; senão cria a partir do HEAD atual
$existsRemote = $false
try {
  $ls = (git ls-remote --heads origin $Branch) -ne $null
  if ($ls) { $existsRemote = $true }
} catch {}

if ($existsRemote) {
  Exec "git worktree add -B $Branch `"$WorktreePath`" origin/$Branch" "Falha ao criar worktree a partir de origin/$Branch"
} else {
  Exec "git worktree add -B $Branch `"$WorktreePath`"" "Falha ao criar worktree local $Branch"
}

# 4) Limpa tudo na worktree exceto .git e copia os artefatos
Push-Location $WorktreePath
Get-ChildItem -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force

# Copia build
Copy-Item ..\accessa_mobile\build\web\* -Destination . -Recurse -Force

# Cria 404.html (fallback SPA) e .nojekyll
@"
<!doctype html><html><head><meta http-equiv='refresh' content='0; url=./index.html'></head><body></body></html>
"@ | Out-File -Encoding utf8 404.html
New-Item -ItemType File -Path .nojekyll -Force | Out-Null

# 5) Commit & push
git add --all
git commit -m "deploy: Flutter Web build (base=$BaseHref, no SW)" | Out-Null

# Se o branch remoto não existia, sobe com -u
if ($existsRemote) {
  git push origin $Branch | Out-Null
} else {
  git push -u origin $Branch | Out-Null
}

Pop-Location

Write-Host ""
Write-Host "✅ Deploy concluído!" -ForegroundColor Green
Write-Host "URL do GitHub Pages: $PagesUrl" -ForegroundColor Yellow
Write-Host "Se ver conteúdo antigo, faça hard reload (Ctrl+Shift+R) ou 'Unregister' do Service Worker nas DevTools." -ForegroundColor DarkYellow
