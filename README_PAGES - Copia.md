# 🌐 Guia de Publicação no GitHub Pages — Accessa (Flutter Web)

Este guia explica **como publicar e manter** a versão Web do Accessa no **GitHub Pages**, com build via **Flutter Web** e deploy automático por **GitHub Actions**.

---

## ✅ Visão Geral

Existem dois fluxos principais:
1) **Local (teste rápido)** — build com `base-href="/"` e servidor local.
2) **Produção (GitHub Pages)** — build com `base-href="/NOME_DO_REPO/"` e deploy para o branch `gh-pages` (automatizado pelo Actions).

> Se você usa **domínio customizado** (CNAME), o `base-href` deve ser `/`.

---

## 🔧 Pré‑requisitos

- Flutter instalado e com Web habilitado:
  ```bash
  flutter --version
  flutter config --enable-web
  ```
- Repositório no GitHub com permissões de **GitHub Actions** e **Pages**.

---

## 🧪 Fluxo Local (desenvolvimento/teste)

Use o script: `build_local.cmd` (Windows) — gera build com `base-href="/"` e sobe um servidor local.

```powershell
.uild_local.cmd
# abrirá http://localhost:8080/
```

Alternativa via Flutter:
```bash
flutter run -d web-server --web-port 8080
```

---

## 🚀 Fluxo Produção (GitHub Pages)

### 1) Build Web com base-href do repositório
Use o script: `build_pages.cmd` (detecta o nome da pasta como NOME_DO_REPO):
```powershell
.uild_pages.cmd
# ou explicitamente:
.uild_pages.cmd accessa_mobile
```

### 2) Deploy automático com GitHub Actions
O workflow `deploy_pages.yml` (em `.github/workflows/`) faz:
- Checkout + setup Flutter
- `flutter build web --release --base-href="/<NOME_DO_REPO>/"`
- Copia `index.html` → `404.html` (SPA routing)
- Publica `build/web/` no branch **`gh-pages`**

> Ele roda em **push** na branch `feat/tela-inicial` e também pode ser disparado manualmente (**workflow_dispatch**).

### 3) Habilitar o GitHub Pages (uma única vez)
No GitHub do repositório:
- **Settings → Pages**  
  - *Source:* **Deploy from a branch**  
  - *Branch:* **gh-pages** / **root**  
- Salve. A URL será algo como:
  ```
  https://<SEU_USUARIO>.github.io/<NOME_DO_REPO>/
  ```

---

## 🌍 Domínio customizado (CNAME)

Se for usar um domínio próprio (ex.: `accessa.suaempresa.com`):
1. Crie o arquivo `CNAME` contendo apenas o domínio:
   ```
   accessa.suaempresa.com
   ```
2. Para **deploy automático**, você pode:
   - **Opção A (Workflow):** gerar o `CNAME` dentro de `build/web` antes do passo de deploy (adicionar um passo `run: echo accessa.suaempresa.com > build/web/CNAME`).  
   - **Opção B (Pages Settings):** definir o domínio em **Settings → Pages → Custom domain** (o Pages cria o `CNAME` automaticamente).
3. **Altere o base-href para `/`** nos builds destinados ao domínio customizado:
   ```bash
   flutter build web --release --base-href="/"
   ```

---

## 🧭 Roteamento SPA (404.html)

Aplicações Flutter Web funcionam como SPA. No Pages, quando você acessa uma rota “profunda” (ex.: `/devices`), o servidor tenta servir `/devices/index.html`.  
Para evitar 404, copie `index.html` para `404.html`:
```bash
# já automatizado no workflow
cp build/web/index.html build/web/404.html
```
Assim, o Pages entrega `404.html` (que é o app) e o Flutter cuida do roteamento.

---

## 🛠️ Troubleshooting

### 1) **404 em assets (flutter_bootstrap.js / manifest.json / favicon)**
- Causa: `base-href` incorreto.  
- Solução: verifique a tag `<base href="...">` no `build/web/index.html`.
  - Para **localhost** → use `/`
  - Para **GitHub Pages** (repo padrão) → use `/<NOME_DO_REPO>/`
  - Para **domínio customizado** → use `/`

### 2) Página abre mas fica “em branco”
- Limpe cache/Service Worker do navegador (DevTools → Application → Service Workers → *Unregister*).
- Faça `flutter clean` e gere um novo build web.
- Verifique erros no console (DevTools → Console).

### 3) Erro de conteúdo misto (Mixed Content)
- Se o app for servido por **HTTPS**, recursos externos (APIs, MQTT-over-WebSocket) também precisam ser **HTTPS/WSS**.

### 4) Build certo, mas URL errada
- Confirme a URL final do Pages em **Settings → Pages**.
- Se renomear o repositório, gere novo build com o `base-href` atualizado.

### 5) Deploy não dispara
- Confirme se o push foi na branch monitorada pelo workflow (ex.: `feat/tela-inicial`).  
- Rode manualmente em **Actions → Deploy Flutter Web to GitHub Pages → Run workflow**.

---

## 🧹 Limpeza de cache/Service Worker
Se ocorrer comportamento antigo após publicar uma nova versão:
1. `flutter clean`
2. `flutter build web ...`
3. No navegador: DevTools → Application → *Unregister* Service Worker → Hard Reload

---

## 🧪 Verificação final (checklist)

- [ ] `flutter config --enable-web` feito
- [ ] Build local funciona com `base-href="/"`
- [ ] Workflow `deploy_pages.yml` está em `.github/workflows/`
- [ ] Pages habilitado para o branch `gh-pages`
- [ ] (Opcional) `CNAME` configurado e `base-href="/"` para domínio customizado
- [ ] URL final testada em aba anônima

---

## 🔗 Referência de comandos

Local:
```bash
flutter build web --release --base-href="/"
python -m http.server -d build/web 8080
```

GitHub Pages (repo padrão):
```bash
flutter build web --release --base-href="/NOME_DO_REPO/"
```

Domínio customizado:
```bash
flutter build web --release --base-href="/"
echo accessa.suaempresa.com > build/web/CNAME
```

---

## 📌 Observações de segurança

- GitHub Pages serve **conteúdo estático**; **não** exponha segredos ou tokens no front-end.
- Para integrações (API/MQTT), use endpoints HTTPS/WSS e cuide de CORS.

---

**Pronto!** Seu pipeline está preparado para publicar o Accessa no GitHub Pages de forma consistente e reproduzível. ✅
