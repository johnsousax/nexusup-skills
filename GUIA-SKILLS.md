# Guia de Skills de Segurança NexusUp (em português)

As 87 skills do acervo, agrupadas, com **o que cada uma faz** e quando usar. Feito para estudo e
para melhorar a segurança — uso **sempre autorizado**.

> Como ler: cada linha é `nome-da-skill` — o que faz. No Claude Code, você invoca por `/nome`.

---

## 🧭 Metodologia e processo (por onde começar)

- **bb-methodology** — O orquestrador. Diz por onde começar e o que fazer em cada fase da caça.
- **bug-bounty** — O fluxo completo: recon → aprendizado → caça → encadeamento → relatório.
- **bb-local-toolkit** — Igual ao bug-bounty, mas sabe onde ficam as ferramentas e wordlists na máquina.
- **recon-scope-triage** — Define o escopo, mapeia a superfície e prioriza o que testar primeiro.
- **redteam-mindset** — A cabeça do atacante: psicologia do dev, achar anomalias, experimentos "e se".
- **evidence-hygiene** — Capturar prova sem vazar: mascarar cookies, tokens e dados pessoais (LGPD).
- **triage-validation** — Validar o achado: reproduzir, provar impacto real, descartar falso-positivo.
- **report-writing** — Escrever o relatório com tom humano, CVSS, PoC e modelos por tipo de falha.
- **redteam-report-template** — Modelo pronto de relatório de red team.
- **bugcrowd-reporting** — Táticas de relatório específicas da plataforma Bugcrowd (VRT, severidade).
- **security-arsenal** — Arsenal de referência de ferramentas e técnicas.

## 🔎 Reconhecimento e OSINT

- **web2-recon** — Recon de alvo web: subdomínios, ativos vivos, tecnologias.
- **offensive-osint** — OSINT ofensivo: achar segredos, e-mails e ativos expostos (vem com scripts).
- **osint-methodology** — Metodologia de OSINT passo a passo.
- **supply-chain-attack-recon** — Recon de cadeia de suprimentos (dependências, pacotes, build).

## 🎯 Caça de falhas — acesso e identidade

- **hunt-idor** — IDOR: ler/alterar dados de outro usuário trocando o ID.
- **hunt-auth-bypass** — Burlar a autenticação (SAML, JWT, SSO, diferenças de parser).
- **hunt-ato** — Tomada de conta (account takeover): 9 caminhos e como encadeá-los.
- **hunt-forgot-password** — Falhas no "esqueci a senha" (token fraco, host-header, vazamento).
- **hunt-mfa-bypass** — Burlar o segundo fator (MFA / 2FA).
- **hunt-session** — Falhas de sessão (fixation, não expira, cookies).
- **hunt-oauth** — Falhas de OAuth (redirect_uri frouxo, roubo de código, CSRF de login).
- **hunt-saml** — Ataques a SAML (XSW, assinatura, comentário, XXE na asserção).
- **hunt-jwt-crypto** — Forjar token JWT (alg:none, confusão de chave, kid/jku).
- **hunt-brute-force** — Falta de limite: brute force de login/OTP, enumeração de usuário.
- **hunt-captcha-bypass** — Burlar CAPTCHA (campo omitido, token reusado, valor fixo).

## 🎯 Caça de falhas — injeção e execução

- **hunt-sqli** — Injeção SQL.
- **hunt-nosqli** — Injeção NoSQL (operadores `$ne`, `$gt`).
- **hunt-xss** — Cross-site scripting (refletido e armazenado).
- **hunt-dom** — DOM XSS: falhas no JavaScript do cliente (sinks perigosos).
- **hunt-html-injection** — Injeção de HTML (sem execução de script).
- **hunt-ssti** — Injeção em template no servidor (`{{7*7}}`).
- **hunt-ssrf** — SSRF: fazer o servidor acessar o interno / metadados de nuvem.
- **hunt-xxe** — XML External Entity: ler arquivo ou SSRF via XML.
- **hunt-rce** — Execução remota de código.
- **hunt-deserialization** — Desserialização insegura (cadeias de gadget).
- **hunt-lfi** — Local File Inclusion / path traversal.
- **hunt-ldap** — Injeção LDAP.
- **hunt-file-upload** — Falhas no upload de arquivo (tipo, extensão, execução).

## 🎯 Caça de falhas — aplicação e API

- **hunt-dispatch** — Roteador: dado o alvo, aponta qual hunt-* usar.
- **hunt-api-misconfig** — Má config de API: mass assignment, prototype pollution, verbo HTTP.
- **hunt-graphql** — Falhas em GraphQL (introspection, batching, IDOR por node).
- **hunt-grpc** — Falhas em gRPC.
- **hunt-websocket** — Falhas em WebSocket.
- **hunt-cors** — CORS mal configurado (reflete a origem + credenciais).
- **hunt-csrf** — Cross-Site Request Forgery.
- **hunt-clickjacking** — Clickjacking (iframe invisível, UI redressing).
- **hunt-open-redirect** — Redirecionamento aberto.
- **hunt-host-header** — Injeção de Host header (reset de senha, SSRF de roteamento).
- **hunt-cache-poison** — Envenenamento de cache / Web Cache Deception.
- **hunt-http-smuggling** — HTTP Request Smuggling.
- **hunt-race-condition** — Condição de corrida (corrida de checkout, cupom empilhável).
- **hunt-business-logic** — Falhas de lógica de negócio (preço no cliente, quantidade negativa).
- **hunt-exceptional-conditions** — Condições excepcionais e casos de borda.
- **hunt-shadow-api** — APIs "fantasma", não documentadas.
- **hunt-spa-api** — APIs por trás de single-page apps (SPA).
- **hunt-source-leak** — Código-fonte e segredos vazados.
- **hunt-misc** — Falhas diversas que não entram nas outras categorias.

## 🧱 Caça por tecnologia (stack)

- **hunt-nextjs** — Falhas específicas de Next.js.
- **hunt-nodejs** — Falhas específicas de Node.js.
- **hunt-laravel** — Falhas específicas de Laravel (PHP).
- **hunt-springboot** — Falhas específicas de Spring Boot (Java).
- **hunt-aspnet** — Falhas de ASP.NET (ViewState, machineKey).
- **hunt-sharepoint** — Falhas de SharePoint.

## ☁️ Nuvem e infraestrutura

- **hunt-cloud-misconfig** — Má config de nuvem: buckets públicos, IMDS via SSRF, serverless.
- **cloud-iam-deep** — IAM de nuvem a fundo (AWS/Azure/GCP): escalar privilégio após achar credencial.
- **hunt-k8s** — Kubernetes exposto / tokens de service account.
- **hunt-cicd** — Pipelines CI/CD (GitHub Actions, Jenkins, runners).
- **hunt-tls-network** — TLS fraco e falhas de rede.
- **hunt-subdomain** — Subdomain takeover (CNAME pendente).

## 🏢 Identidade corporativa e Active Directory

- **m365-entra-attack** — Ataque a Microsoft 365 / Entra ID (Azure AD).
- **okta-attack** — Ataque a Okta.
- **enterprise-vpn-attack** — Appliances de VPN (Cisco, Fortinet, Citrix, Pulse, Palo Alto...).
- **vmware-vcenter-attack** — Ataque a VMware vCenter.
- **hunt-ntlm-info** — Vazamento de informação via NTLM.

## 📱 Mobile

- **apk-redteam-pipeline** — Red team de app Android: baixar o APK, decompilar, grep de segredos, Frida.
- **ios-redteam-pipeline** — Red team de app iOS.

## 🤖 IA / LLM

- **hunt-llm-ai** — Segurança de IA/LLM: prompt injection, exfiltração, RCE via ferramenta de código.
- **hunt-rag-vector** — Segurança de RAG e bancos vetoriais.

## 🪙 Cripto / Web3 / Fintech

- **web3-audit** — Auditoria de contratos Web3 / blockchain.
- **meme-coin-audit** — Auditoria de meme coins e tokens.
- **hunt-fintech-graphql** — GraphQL em fintech (foco financeiro).

## 🔬 Engenharia reversa e resposta a incidente

- **reverse-engineer-anything** — Engenharia reversa de qualquer coisa (binário, app, bundle):
  vê como cada mecânica se encaixa no sistema. Usa Ghidra, jadx e Frida (ferramenta REA).
- **mid-engagement-ir-detection** — Detecção e resposta a incidente no meio de um engajamento.
- **nexusup-reversa** — O jeito NexusUp de usar o REA: mapear as mecânicas de um app e entregar relatório de entendimento + melhoria.

## ⭐ Skills NexusUp (suas)

- **nexusup-pentest** — O kit de campo: conduz o pentest de ponta a ponta **sem instalar nada**.
- **nexusup-seguranca** — Opera a plataforma autônoma (ARTEX) para corridas longas.
- **nexusup-reversa** — Engenharia reversa no padrão NexusUp: entender como um sistema funciona por dentro (REA) e gerar relatório para o cliente ou para melhorar o app.
- **nexusup-identidade** — O sistema de design NexusUp (cores, fonte Geist, logos) para os entregáveis.

---

<sub>NexusUp Company · guia de skills · uso autorizado apenas</sub>
