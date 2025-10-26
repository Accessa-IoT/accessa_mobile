# 🌐 Guia de Deploy — GitHub Pages (Flutter Web)

Este guia foca no **deploy com `deploy.ps1`** para publicar a versão Web no **GitHub Pages**. O script automatiza build, cópia para a branch `gh-pages` via **worktree** e o push final.

---

## ✅ Requisitos
- Flutter com Web habilitado: `flutter config --enable-web`
- Git instalado e remoto `origin` configurado
- GitHub Pages habilitado em **Settings → Pages** (Source: `gh-pages` / `(root)`)

---

## 🚀 Uso rápido
Na raiz do repositório:
```powershell
# (se necessário, liberar scripts nesta sessão)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\deploy.ps1
```
O script:
- faz `flutter build web --release --base-href "/<repo>/" --pwa-strategy=none`;
- cria/atualiza a worktree `..\_site` para `gh-pages`;
- copia os artefatos (preservando `.git`), adiciona `404.html` e `.nojekyll`;
- comita e dá push para `origin/gh-pages`;
- imprime a URL final.

---

## 🧩 Parâmetros disponíveis
```powershell
.\deploy.ps1 -SkipClean
.\deploy.ps1 -Branch gh-pages -WorktreePath ..\_site
.\deploy.ps1 -RepoName accessa_mobile -Owner Accessa-IoT
```

---

## 🔧 Dicas e Solução de Problemas
- **Base HREF**: para GitHub Pages padrão, use `"/<repo>/"`; para domínio customizado (CNAME), use `"/"`.
- **Cache/Service Worker**: se ver versão antiga, faça *hard reload* (**Ctrl+Shift+R**) ou *Unregister* do SW (DevTools → Application).
- **Branch `gh-pages` inexistente**: o script cria localmente e sobe com `-u origin gh-pages`.
- **Roteamento SPA**: `404.html` é gerado a partir do `index.html` para evitar 404 em rotas internas.

---

## ♻️ (Opcional) Deploy automático por GitHub Actions
Caso prefira CI/CD, crie `.github/workflows/gh-pages.yml` com:
```yaml
name: Deploy Flutter Web to GH Pages
on:
  push:
    branches: [ main ]
permissions:
  contents: write
jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter build web --release --base-href /${{ github.event.repository.name }}/ --pwa-strategy=none
      - run: cp build/web/index.html build/web/404.html
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: build/web
          force_orphan: true
```
> Ajuste a branch de disparo conforme seu fluxo (ex.: `main`, `develop`). O base-href usa o nome do repo automaticamente.
