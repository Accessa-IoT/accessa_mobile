# 📱 Projeto Mobile – Accessa

Aplicativo móvel para controle seguro de acessos via IoT (ESP8266), parte do Projeto Integrador II.  
O app permite autenticação segura, abertura de dispositivos e monitoramento de logs de acesso, integrando-se com a API backend e dispositivos físicos.

---

## 🚀 Tecnologias
- Flutter
- Integração com API REST
- Autenticação segura (JWT)
- Integração com ESP8266 (via Wi-Fi/MQTT)

---

## 📂 Estrutura do Projeto
```
/src
  /components   → Componentes reutilizáveis
  /screens      → Telas do aplicativo
  /services     → Comunicação com API/IoT
  /utils        → Funções auxiliares
```

---

## 🛠️ Instalação e Execução

### 1. Pré-requisitos
- **Flutter SDK** instalado (versão 3.0 ou superior).  
- **Dart SDK** já incluído no Flutter.  
- Dispositivo Android/iOS ou emulador configurado.  
- (Opcional) Backend e broker MQTT rodando para integração completa.  

Verifique a instalação do Flutter:
```bash
flutter doctor
```

### 2. Clonando o repositório
```bash
git clone https://github.com/seu-usuario/projeto-mobile.git
cd projeto-mobile
```

### 3. Instalando dependências
```bash
flutter pub get
```

### 4. Executando o app
- **Execução padrão (detecta o dispositivo/emulador disponível):**
  ```bash
  flutter run
  ```

- **Forçar execução em plataforma específica:**
  ```bash
  flutter run -d android   # Em um dispositivo Android/emulador
  flutter run -d ios       # Em um dispositivo iOS/simulador
  flutter run -d web       # Executar no navegador (se habilitado)
  ```

### 5. Exemplos de uso
- **Executar em modo debug (com hot reload):**
  ```bash
  flutter run --debug
  ```

- **Executar em modo release (otimizado, sem debug banner):**
  ```bash
  flutter run --release
  ```

- **Gerar build APK (Android):**
  ```bash
  flutter build apk --release
  ```

- **Gerar build AppBundle (Android, para Play Store):**
  ```bash
  flutter build appbundle --release
  ```

- **Gerar build para iOS (necessário macOS + Xcode):**
  ```bash
  flutter build ios --release
  ```

---

## 📌 Convenções de Commits

Este projeto segue o padrão [Conventional Commits](https://www.conventionalcommits.org/).

- `feat:` → Nova funcionalidade  
- `fix:` → Correção de bug  
- `docs:` → Alterações em documentação  
- `style:` → Formatação, espaços, ponto e vírgula, etc. (sem mudança de lógica)  
- `refactor:` → Refatoração de código  
- `test:` → Adição ou alteração de testes  
- `chore:` → Atualizações de build, dependências, configs  

**Exemplo:**
```
feat(login): adiciona autenticação com 2FA
fix(api): corrige timeout na chamada de abertura de porta
```

---

## 🌱 Como Contribuir

1. **Crie uma issue** descrevendo a tarefa/bug/feature no GitHub.  
   - Ex.: *“Implementar tela de login com integração à API”*.  

2. **Crie uma branch** a partir da `main`:
   ```bash
   git checkout -b {numero-issue}-login-tela
   ```

3. **Implemente sua tarefa** e faça commits seguindo as convenções.  

4. **Abra um Pull Request (PR)**:  
   - Descreva o que foi feito.  
   - Relacione a issue correspondente.  
   - Solicite revisão de pelo menos 1 colega.  

5. Após aprovação, o líder/maintainer fará o **merge** na `main`.

---

## ✅ Boas Práticas

- Sempre escreva commits claros e pequenos.  
- Atualize sua branch com a `main` antes de abrir PR:  
  ```bash
  git pull origin main --rebase
  ```
- Nunca commitar diretamente na `main`.  
- Documente novas telas, endpoints ou fluxos no README ou Wiki.  
- Revise PRs dos colegas antes de aprovar.  

---

## 📖 Licença
Este projeto é acadêmico e faz parte do **Projeto Integrador II** do curso de **Tecnologia em Sistemas para Internet (IFRN)**.

---

## 🌐 Deploy no GitHub Pages (com `deploy.ps1`)

Este repositório inclui um script de deploy que publica a versão **Flutter Web** no GitHub Pages usando **worktree**.

### Pré‑requisitos
- `git` e `flutter` no `PATH`
- Permissões de **GitHub Pages** habilitadas no repositório
- (Opcional) habilitar scripts por sessão no PowerShell:
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```

### Passo a passo
1. Gere a build Web com base correta e sem service worker (o script faz isso automaticamente):
   ```powershell
   .\deploy.ps1
   ```
   O script irá:
   - rodar `flutter build web --release --base-href "/<nome_do_repo>/" --pwa-strategy=none`;
   - criar/atualizar uma **worktree** em `..\_site` para a branch `gh-pages`;
   - copiar os artefatos da build preservando o `.git`;
   - criar `404.html` e `.nojekyll`;
   - fazer `git commit` e `git push` para `origin/gh-pages`;
   - exibir a URL final (ex.: `https://<Owner>.github.io/<Repo>/`).

2. Confirme em **Settings → Pages** se a fonte está como **gh-pages / (root)**.

### Opções úteis
```powershell
.\deploy.ps1 -SkipClean                          # mais rápido (não roda flutter clean)
.\deploy.ps1 -Branch gh-pages -WorktreePath ..\_site
.\deploy.ps1 -RepoName accessa_mobile -Owner Accessa-IoT
```

### Troubleshooting
- **Página desatualizada:** faça *hard reload* (**Ctrl+Shift+R**) ou, nas DevTools → *Application* → *Service Workers*, clique **Unregister**.
- **404 em assets (manifest, favicon, flutter_bootstrap.js):** gere a build com o `--base-href` correto (`"/<repo>/"`). Para domínio customizado, use `"/"`.
- **Deploy falhou:** verifique se a branch `gh-pages` existe no remoto e se o script conseguiu criar a worktree.
