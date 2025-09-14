# Accessa – Visão de Arquitetura

## 1. Escopo
Aplicativo + IoT para controle de acesso físico auditável (portas/armários) em PMEs. Usuários autorizados abrem com 1 toque; tudo fica registrado.

## 2. Público-alvo
Pequenas e médias organizações (escolas, labs, coworkings, makerspaces, pequenas empresas).

## 3. Requisitos Funcionais (RF)
- RF01 Autenticação no app (e-mail/senha + TOTP opcional).
- RF02 Solicitar abertura de porta/armário pelo app.
- RF03 Token de uso único (nonce + timestamp) assinado via HMAC por solicitação.
- RF04 Envio via MQTT/TLS: `accessa/<deviceId>/cmd`.
- RF05 Firmware (ESP8266) valida assinatura/tempo (±30s via NTP) e chave por dispositivo.
- RF06 Acionamento do relé por N segundos + LED/Buzzer de estado.
- RF07 Log de eventos (quem/o quê/quando/onde/resultado) com hash/assinatura.
- RF08 Histórico com filtros no app (data/usuário/dispositivo/resultado).
- RF09 Gestão (perfis, permissões por horário/dispositivo) para admins.
- RF10 Notificações de tentativas inválidas e eventos críticos (push).
- RF11 Fallback offline seguro por PIN temporário (gera admin; registra assim que online).

## 4. Requisitos Não Funcionais (RNF) – segurança & desempenho
- TLS 1.2+ app↔broker e broker↔dispositivo; HMAC-SHA-256 + nonces únicos; rotação/revogação de chaves.
- Hardening firmware: verificação de integridade na inicialização, watchdog, OTA assinado.
- LGPD: minimização, consentimento, retenção/descartes conforme política.
- Latência ponta-a-ponta < 1,5 s LAN; disponibilidade ≥ 99%; reconexão automática ao broker.
- App Android 9+; acessibilidade (contraste/tamanhos/feedback) e i18n pt-BR.
- Observabilidade: logs JSON com níveis e correlação (deviceId/requestId); telemetria (uptime, RSSI, versão FW).

## 5. Componentes
- **App Mobile (Flutter)**: autenticação (JWT + TOTP), emissão de comandos, histórico e filtros.
- **Broker MQTT (TLS)**: tópicos `accessa/<deviceId>/cmd` e `accessa/<deviceId>/evt`.
- **Dispositivo (ESP8266)**: relé/solenóide, reed switch (porta), buzzer, LED RGB.
- **API/Backend**: persistência de logs assinados, notificações, gestão de usuários/permissões.

## 6. Fluxo Básico
1) Usuário autenticado solicita abertura (deviceId).
2) App cria payload `{requestId, deviceId, userId, timestamp, nonce, hmac}`.
3) Publica em `accessa/<deviceId>/cmd` (MQTT/TLS).
4) Dispositivo valida assinatura/tempo/estado sensor → aciona relé N s.
5) Publica resultado em `accessa/<deviceId>/evt`.
6) API grava log assinado e dispara notificação (se configurada).

## 7. Segurança de Chaves
- Chave simétrica única por dispositivo; rotação e revogação documentadas.
- Janela de validade de token (±30 s) e rejeição de replay por nonce cacheado.
- OTA de firmware assinado; watchdog e verificação de integridade no boot.

## 8. Operação Offline (Fallback)
- PIN local temporário gerado por admin, com expiração e escopo; sincroniza logs ao voltar a conexão.

## 9. Métricas/Telemetria
- Uptime, RSSI, versão do firmware, contagem de falhas de validação, eventos críticos, temperatura MCU (se disponível).

## 10. Próximos Passos
- Especificar schema dos tópicos MQTT e payloads (JSON).
- Definir política de rotação de chaves e de retenção de logs.
- Esboçar telas do app para histórico/filtros e administração.
