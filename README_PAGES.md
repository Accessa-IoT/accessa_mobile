# 🌐 Guia de Publicação no GitHub Pages — Accessa (Flutter Web)

Este documento orienta o processo completo de **publicação e manutenção da versão Web** do projeto **Accessa**, utilizando **Flutter Web**, **GitHub Actions** e **GitHub Pages**.  
Inclui instruções para builds locais, produção, domínio customizado e troubleshooting.

---

## ✅ Visão Geral

O Accessa Web pode ser executado em dois fluxos principais:

| Fluxo | Descrição |
|--------|------------|
| 🧪 **Local (teste rápido)** | Build com `base-href="/"`, executado em servidor local. |
| 🚀 **Produção (GitHub Pages)** | Build com `base-href="/NOME_DO_REPO/"` e deploy automático para o branch `gh-pages`. |

> Se for usado **domínio customizado** (CNAME), o `base-href` deve ser `/`.

---

## 🔧 Pré-requisitos

- Flutter instalado e com suporte Web habilitado:
  ```bash
  flutter --version
  flutter config --enable-web
  ```
- Repositório hospedado no GitHub com **GitHub Actions** e **GitHub Pages** ativados.

---

## 🧪 Execução Local (Desenvolvimento/Teste)

Use o script `build_local.cmd` para gerar o build com `base-href="/"` e iniciar um servidor local.

```powershell
.\build_local.cmd
# abrirá em http://localhost:8080/
```

Ou alternativamente via Flutter:
```bash
flutter run -d web-server --web-port 8080
```

---

## 🚀 Publicação em Produção (GitHub Pages)

### 1️⃣ Build com base-href do repositório
O script `build_pages.cmd` detecta automaticamente o nome da pasta como `NOME_DO_REPO`:
```powershell
.\build_pages.cmd
# ou explicitamente:
.\build_pages.cmd accessa_mobile
```

### 2️⃣ Deploy automático via GitHub Actions
O workflow `deploy_pages.yml` (em `.github/workflows/`) realiza:
- Checkout e setup do Flutter;
- Build Web com `flutter build web --release --base-href="/<NOME_DO_REPO>/"`;
- Criação do `404.html` para rotas SPA;
- Publicação de `build/web/` no branch **`gh-pages`**.

> O deploy é acionado a cada **push** na branch de origem configurada (ex.: `feat/tela-inicial`) ou manualmente via **workflow_dispatch**.

### 3️⃣ Habilitar o GitHub Pages (primeira vez)
No repositório GitHub:
- Vá em **Settings → Pages**
- Configure:
  - **Source:** *Deploy from a branch*
  - **Branch:** *gh-pages / root*
- Após salvar, o site ficará disponível em:
  ```
  https://<SEU_USUARIO>.github.io/<NOME_DO_REPO>/
  ```

---

## 🌍 Domínio Customizado (CNAME)

Para usar um domínio próprio (ex.: `accessa.exemplo.com`):

1. Crie o arquivo `CNAME` com o domínio:
   ```text
   accessa.exemplo.com
   ```

2. Gere o CNAME automaticamente (opcional):
   ```yaml
   - name: Criar CNAME
     run: echo accessa.exemplo.com > build/web/CNAME
   ```

3. Ajuste o comando de build para `base-href="/"`:
   ```bash
   flutter build web --release --base-href="/"
   ```

> Também é possível definir o domínio diretamente nas configurações do Pages (**Settings → Pages → Custom domain**).

---

## 🧭 Roteamento SPA (404.html)

Por padrão, o GitHub Pages tenta buscar um arquivo físico para cada rota, o que causa erros 404.  
Para corrigir isso, copie o arquivo `index.html` para `404.html`:

```bash
# já automatizado no workflow
cp build/web/index.html build/web/404.html
```

Assim, qualquer rota retorna o app Flutter (Single Page Application).

---

## 🛠️ Solução de Problemas (Troubleshooting)

| Problema | Causa Provável | Solução |
|-----------|----------------|----------|
| **404 em assets (flutter_bootstrap.js, manifest.json, favicon)** | `base-href` incorreto | Corrigir a tag `<base href>` no `index.html`. Use `/` (local) ou `/<NOME_DO_REPO>/` (GitHub Pages). |
| **Página em branco após deploy** | Cache antigo ou Service Worker obsoleto | Limpar cache → *DevTools → Application → Service Workers → Unregister*. |
| **Erro Mixed Content (conteúdo inseguro)** | Recursos externos usando HTTP em vez de HTTPS | Garanta que tudo use HTTPS/WSS. |
| **URL incorreta após rename do repositório** | `base-href` desatualizado | Rebuild com novo nome do repositório. |
| **Deploy não acionado** | Push fora da branch monitorada | Enviar para a branch correta ou acionar manualmente em *Actions*. |

---

## 🧹 Limpeza de Cache / Service Worker

Quando ocorrer comportamento inconsistente após um novo deploy:
1. Execute `flutter clean`;
2. Gere o build novamente;
3. No navegador: *DevTools → Application → Unregister Service Worker → Hard Reload*.

---

## 🧪 Checklist Final

- [x] `flutter config --enable-web` executado  
- [x] Build local validado (`base-href="/"`)  
- [x] Workflow `deploy_pages.yml` criado  
- [x] GitHub Pages habilitado (`gh-pages`)  
- [x] CNAME configurado (se aplicável)  
- [x] URL final testada em aba anônima  

---

## 🔗 Referência Rápida de Comandos

### Execução local:
```bash
flutter build web --release --base-href="/"
python -m http.server -d build/web 8080
```

### Publicação padrão (repositório GitHub):
```bash
flutter build web --release --base-href="/NOME_DO_REPO/"
```

### Domínio customizado:
```bash
flutter build web --release --base-href="/"
echo accessa.exemplo.com > build/web/CNAME
```

---

## 🔒 Observações de Segurança

- O GitHub Pages serve apenas **conteúdo estático** — não armazene senhas, chaves ou tokens.
- Todas as comunicações com o broker MQTT devem usar **WSS (WebSocket Secure)**.
- APIs e endpoints externos devem estar sob **HTTPS** para evitar bloqueios de navegador.

---

## ✅ Conclusão

O pipeline de publicação do **Accessa Web** está preparado para **builds reproduzíveis, automação completa de deploy e compatibilidade com HTTPS/WSS**.  
Seguindo este guia, é possível garantir uma implantação confiável e segura tanto em **GitHub Pages** quanto em **domínios personalizados**.
