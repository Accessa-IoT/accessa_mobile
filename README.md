# 📱 Accessa — Controle de Acesso Inteligente via IoT

O **Accessa** é um aplicativo desenvolvido em **Flutter** para controle seguro de acessos utilizando tecnologias **IoT**, **MQTT** e **autenticação via API**.  
Faz parte do **Projeto Integrador II** do curso de **Tecnologia em Sistemas para Internet (IFRN)** e foi projetado para integrar **usuários, dispositivos físicos (ESP8266)** e **um backend de autenticação** em um ecossistema unificado e escalável.

---

## 🧠 Visão Geral do Projeto

O **Accessa** permite que usuários **autenticados** controlem remotamente dispositivos (como fechaduras elétricas ou portas automatizadas) e monitorem logs de acesso em tempo real, tudo por meio da nuvem.  
O sistema usa o **HiveMQ Cloud** como broker MQTT e foi projetado para futura integração com **dispositivos físicos ESP8266** e **servidores REST**.

---

## ⚙️ Arquitetura e Integrações

### 🔐 Camada de Autenticação
- Autenticação segura com **JWT (JSON Web Token)**;
- Armazenamento de sessão criptografada via `shared_preferences`.

### 📡 Camada IoT (MQTT)
- Integração com **HiveMQ Cloud (Serverless Free)**;
- Comunicação bidirecional com tópicos hierárquicos (`accessa/#`);
- Conexão híbrida (TLS 8883 e WebSocket 8884 via detecção automática `kIsWeb`);
- Tela de diagnóstico MQTT (`/mqtt_diag`) para debug e teste de conexão.

### 🌐 Camada de API (REST)
- Integração futura com backend para autenticação centralizada e logs persistentes.

### 📲 Camada de Apresentação (Frontend Flutter)
- Interface desenvolvida em **Material Design 3 (Material You)**;
- Suporte a modo **Web, Android e Windows Desktop**;
- Telas modulares e de fácil navegação via `Navigator.pushNamed()`.

---

## 🧩 Estrutura do Projeto

```
/lib
  /components     → Widgets reutilizáveis (botões, campos, diálogos)
  /screens        → Telas principais do app
    /auth         → Login, registro e recuperação
    /devices      → Listagem e controle de dispositivos
    /mqtt         → Tela de integração e diagnóstico HiveMQ
    /history      → Histórico de acessos
    /admin        → Funções administrativas
  /services       → Serviços de backend e IoT
    mqtt_service.dart    → Conexão híbrida (TLS/WSS)
    mqtt_config.dart     → Configurações do broker HiveMQ
    auth_service.dart    → Controle de autenticação
    storage.dart         → Persistência local
  /utils          → Funções auxiliares e helpers
```

---

## 🚀 Execução e Deploy

### 1️⃣ Pré-requisitos
- **Flutter SDK** (versão 3.0+);
- **Dart SDK** (já incluso);
- **Conta no HiveMQ Cloud** para integração MQTT;
- (Opcional) **API REST** local para autenticação real.

Verifique o ambiente:
```bash
flutter doctor
```

### 2️⃣ Clonando o Repositório
```bash
git clone https://github.com/seu-usuario/accessa.git
cd accessa
```

### 3️⃣ Instalando Dependências
```bash
flutter pub get
```

### 4️⃣ Executando o App
- **Execução padrão (detecta automaticamente):**
  ```bash
  flutter run
  ```

- **Execução em modo Web:**
  ```bash
  flutter run -d chrome
  ```

- **Execução em Windows (desktop):**
  ```bash
  flutter run -d windows
  ```

- **Build de produção:**
  ```bash
  flutter build web --release --base-href="/accessa/"
  ```

---

## 🌍 Integração MQTT (HiveMQ Cloud)

### Configuração do Broker
```
Host: b57e703be5e8423287c46b91e5714e83.s1.eu.hivemq.cloud
Portas:
  - 8883 (TLS)
  - 8884 (WebSocket Secure)
Username: app_accessa
Password: Bx@EXHuLvw.V7X6
Tópico base: accessa/#
```

### Estrutura de Tópicos
```
accessa/
 ├── porta01/
 │    ├── status     → Estado da porta (aberta, trancada)
 │    ├── comando    → Ações enviadas (abrir, travar)
 │    └── sensor     → Leituras simuladas
 ├── porta02/
 │    ├── status
 │    └── comando
 └── admin/
      └── log        → Logs administrativos
```

### Tela de Diagnóstico MQTT
O app inclui a tela `/mqtt_diag`, que testa as conexões via TLS e WSS.  
Ela exibe resultados de conexão, mensagens de erro e feedback visual em tempo real (chips coloridos com status).

---

## 📊 Funcionalidades Implementadas

| Categoria | Descrição | Status |
|------------|------------|--------|
| Autenticação segura | Login e registro com validação local | ✅ |
| Controle de dispositivos | Lista e controle remoto de portas | ✅ |
| Histórico de acesso | Visualização dos logs | ✅ |
| Diagnóstico MQTT | Testes de conexão TLS/WSS | ✅ |
| Integração HiveMQ Cloud | Broker configurado e funcional | ✅ |
| Conexão híbrida automática | TLS no Desktop, WSS no Web | ✅ |
| Integração com ESP8266 | Simulada (base pronta para integração real) | ⚙️ |

---

## 🔧 Scripts Úteis

| Comando | Descrição |
|----------|------------|
| `flutter clean` | Limpa cache e builds antigos |
| `flutter pub get` | Instala dependências |
| `flutter pub upgrade` | Atualiza bibliotecas |
| `flutter run -d windows` | Executa em desktop |
| `flutter run -d chrome` | Executa em navegador |
| `flutter build apk --release` | Gera APK para Android |

---

## 🧠 Convenções de Commits

Segue o padrão [Conventional Commits](https://www.conventionalcommits.org/).

- `feat:` → Nova funcionalidade  
- `fix:` → Correção de bug  
- `docs:` → Alterações de documentação  
- `refactor:` → Refatoração de código  
- `test:` → Adição de testes  
- `chore:` → Ajustes de build/configurações  

**Exemplo:**
```
feat(mqtt): adiciona diagnóstico híbrido TLS/WSS
fix(auth): corrige persistência de token JWT
```

---

## 🤝 Contribuindo

1. **Crie uma issue** descrevendo a nova feature ou bug.  
2. **Crie uma branch** a partir da `main`:  
   ```bash
   git checkout -b feat/nome-da-feature
   ```
3. **Implemente, commit e abra um Pull Request (PR)**.  
4. **Solicite revisão de código** a um colega antes do merge.

---

## 🔒 Segurança e Boas Práticas

- Nunca exponha credenciais reais em builds de produção.  
- Utilize `.env` ou `dotenv` para armazenar chaves em versões futuras.  
- Prefira conexões seguras (`https`, `wss`, `tls`).  
- Valide entradas de usuário e autenticação localmente.  

---

## 🎓 Contexto Acadêmico

O projeto **Accessa** representa a aplicação prática dos conteúdos aprendidos na disciplina de **Internet das Coisas (IoT)** do IFRN.  
Foi estruturado para demonstrar:
- Comunicação segura entre app e dispositivos IoT;
- Utilização de protocolos MQTT e REST;
- Integração de frontend e middleware em ambiente cloud.  

---

## 🧾 Licença

Este projeto é acadêmico e faz parte do **Projeto Integrador II – IFRN (2025)**.  
Uso permitido para fins educacionais e demonstrações técnicas.

---

**Desenvolvido com 💙 em Flutter e Dart — Projeto Accessa (IoT + Cloud + Segurança).**
