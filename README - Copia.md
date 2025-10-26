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
