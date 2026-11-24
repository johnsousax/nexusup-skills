<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="brand/nexusup-horizontal-negativo.svg">
  <img src="brand/nexusup-horizontal-cor.svg" alt="NexusUp" width="300">
</picture>

# NexusUp Security — skills & materiais

**Análise de segurança com provas na mão. Sem instalar nada — só skills.**

</div>

---

## Para quem não baixa ferramenta, só usa skill

A NexusUp trabalha segurança de clientes com **skills** que rodam dentro do Claude — nada de
instalar programa ou ferramenta. Copie a pasta da skill para `~/.claude/skills/`, ou, no chat,
cole o prompt pronto. Em minutos você conduz uma análise autorizada do início ao relatório.

> **Uso autorizado apenas.** Tudo aqui é para análise de segurança contratada e autorizada.

## As skills NexusUp

Três skills próprias, abertas aqui para você usar:

### 🛡️ `nexusup-pentest` — o kit de campo
Conduz uma análise de segurança **de ponta a ponta sem instalar nada**: autorização → recon →
mapa de superfície → caça de vulnerabilidade → validação sem falso-positivo → evidência limpa →
relatório assinado. Traz o catálogo de ataques (IDOR, SSRF, XSS, SQLi, auth bypass, GraphQL,
nuvem, IA/LLM...) e um **modelo de relatório** pronto. Também vem como **prompt** para colar em
qualquer IA (`skills/nexusup-pentest/prompt.md`).

### 🤖 `nexusup-seguranca` — a plataforma autônoma
Opera a plataforma de pentest **autônomo multiagente** (planejador + executores + captura de
tráfego + duplo grafo). Para corridas longas e automatizadas, com evidência amarrada a cada
achado e um lado defensivo (assinaturas de detecção Sigma/Suricata).

### 🔬 `nexusup-reversa` — entender como o sistema funciona
Engenharia reversa no padrão NexusUp, com o **REA** (Ghidra, jadx, Frida). Em vez de só achar
falhas, **entende como um sistema funciona por dentro** (binário, APK/iOS, bundle web, firmware):
mapeia as mecânicas, acha segredos embutidos e riscos de design. Dois caminhos: **relatório para
o cliente** (como funciona + o que melhorar) ou **trabalhar no próprio app** e entregar o
**relatório de melhoria** (antes → depois).

### 🎨 `nexusup-identidade` — o sistema de design
A identidade visual NexusUp aplicada a qualquer entregável: cores oficiais (Azul Nexus
`#1F5BFF`, Grafite `#1A1B1F`), fonte **Geist**, logos e o símbolo. Faz o relatório sair com a
cara da marca, pronto para entregar ao cliente.

## O que a NexusUp cobre

Aplicação web e **API**, **nuvem** (AWS/GCP/Azure, K8s, CI/CD), **IA/LLM** (prompt injection,
RAG, agentes), **mobile** (Android/iOS), **identidade e AD** (OAuth, SAML, Okta, Entra), e
**OSINT/recon**. Entrega com prova, conformidade **LGPD** e, de bônus, como o cliente
**detecta** o ataque no futuro.

Detalhes nos documentos:
- **[Avaliação de Cobertura de Segurança](documentos/NexusUp-Avaliacao-de-Seguranca.pdf)** —
  o que avaliamos, com que profundidade, e as skills por trás.
- **[Proposta Comercial (modelo)](documentos/NexusUp-Proposta-Comercial.pdf)** — escopo,
  abordagem, entregáveis e diferenciais.

## Como usar as skills

- **Claude Code:** `cp -R skills/* ~/.claude/skills/` e invoque por nome (ex.: `/nexusup-pentest`).
- **Só no chat:** cole `skills/nexusup-pentest/prompt.md` como primeira mensagem.

---

<div align="center">
<sub>NexusUp Company · análise de segurança autorizada · provas na mão</sub>
</div>
