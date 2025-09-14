# Contribuindo com o Accessa

Obrigado por querer contribuir! 🙌  
Este guia mostra como colaborar de forma organizada e segura.

---

## 🛠 Fluxo de Contribuição

1. **Crie uma branch a partir da `main`:**
   ```bash
   git checkout -b tipo/curta-descricao
   ```
   Exemplos:
   - `feat/login-2fa`
   - `docs/arquitetura-accessa`
   - `fix/mqtt-reconnect`

2. **Implemente suas alterações** (código, testes ou documentação).

3. **Adicione os arquivos ao stage:**
   ```bash
   git add .
   ```

4. **Faça commits pequenos e claros usando Conventional Commits:**
   - `feat:` → nova funcionalidade  
   - `fix:` → correção de bug  
   - `docs:` → mudanças de documentação  
   - `refactor:` → refatorações sem alterar comportamento  
   - `test:` → novos testes ou correções de testes  
   - `chore:` → ajustes de build, configs, dependências  

   Exemplo:
   ```bash
   git commit -m "feat(auth): adiciona autenticação 2FA com TOTP"
   ```

5. **Atualize sua branch com a `main` antes do PR:**
   ```bash
   git pull origin main --rebase
   ```

6. **Envie a branch para o remoto:**
   ```bash
   git push -u origin nome-da-sua-branch
   ```

7. **Abra um Pull Request** no GitHub:
   - Descreva claramente **o que** mudou e **por que**.  
   - Se possível, adicione prints, logs ou referências às issues.  

---

## 📋 Boas Práticas

- Commits pequenos e com mensagens claras.  
- Documente mudanças significativas no código.  
- Sempre adicione testes quando implementar funcionalidades críticas.  
- Não faça commits direto na `main`.  

---

## ✅ Exemplo de PR bem feito

**Título:**  
`feat(auth): implementa login com autenticação 2FA`

**Descrição:**  
- Adicionada autenticação via TOTP.  
- Atualizado fluxo de login para suportar código temporário.  
- Incluída validação de tempo (±30s).  

Closes #12
