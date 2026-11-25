---
name: nexusup-blindagem
description: "Lado defensivo da NexusUp — blindar VPS, sites e sistemas contra invasão e fraude, usando as skills de ataque (hunt-*, osint, cloud, mobile) ao contrário: para cada técnica do invasor, a defesa e o teste. Audita (somente leitura) uma VPS e um site com os scripts auditoria-vps.sh e auditoria-site.sh, revisa código pela lente de cada hunt-*, e entrega plano de endurecimento + relatório no padrão nexusup-identidade. Use quando o usuário quiser proteger o próprio servidor/site/app, fazer hardening, checklist de segurança, antifraude, revisar segurança antes de publicar, ou saber onde pegar/rotacionar credenciais. Só em sistemas do usuário ou autorizados por escrito."
---

# NexusUp Blindagem — proteger antes de ser atacado

Guia completo (MD + PDF): `documentos/NexusUp-Blindagem.md` / `.pdf` no repositório
`johnsousax/nexusup-skills`. Esta skill é o **roteiro de execução** dele.

## Princípio
Para cada porta, chame o especialista que sabe arrombá-la e pergunte: *como você entraria e o que
te impediria?* Defesa = **camadas**: contas → VPS → borda/DNS → aplicação → lógica/fraude →
código/fornecedores → IA/mobile → vigilância.

## Regras
- **Autorização:** só sistemas do usuário ou com autorização escrita. Confirme o alvo antes.
- **Somente leitura por padrão.** Nada de mudar config, reiniciar serviço, rodar scanner ativo
  (nuclei/ZAP/sqlmap) em produção sem o usuário pedir explicitamente.
- Nunca imprima segredos encontrados por inteiro (mostre os 6–12 primeiros caracteres).
- SSH: ao endurecer, **sempre** mandar testar em segundo terminal antes de fechar o primeiro.
- Máquina do usuário é fraca (MacBook Air 2015): prefira rodar ferramentas pesadas **na VPS**.

## Fluxo
1. **Escopo** — domínios, VPS (usuário@IP), repositórios, stack (Next/Supabase/Vercel/Laravel…),
   se há pagamento, IA ou app mobile.
2. **Auditoria passiva do site** — `bash auditoria-site.sh dominio` (HTTPS/TLS, cabeçalhos,
   cookies, arquivos expostos, source maps, segredos no JS, CORS, SPF/DMARC/CAA).
3. **Auditoria da VPS** — copiar `auditoria-vps.sh` e rodar `sudo bash auditoria-vps.sh`
   (SSH, usuários, UFW, portas públicas, fail2ban, sysctl, Docker, arquivos sensíveis). Complementar
   com `sudo lynis audit system`.
4. **Revisão de código** — por stack, carregar as skills de ataque e procurar o padrão defeituoso:

| Tema | Skills | Procurar no código |
|---|---|---|
| Injeção | hunt-sqli, hunt-nosqli, hunt-ssti, hunt-rce, hunt-ldap | query com `${}`/concatenação, `eval`, `exec`, render de template com entrada |
| XSS | hunt-xss, hunt-dom, hunt-html-injection | `dangerouslySetInnerHTML`, `v-html`, `innerHTML`, CSP fraca |
| Auth/sessão | hunt-auth-bypass, hunt-session, hunt-jwt-crypto, hunt-oauth, hunt-saml, hunt-mfa-bypass, hunt-forgot-password, hunt-brute-force, hunt-captcha-bypass | verify JWT sem `algorithms`, reset token fraco, falta de rate limit, logout só no cliente |
| Autorização | hunt-idor, hunt-api-misconfig, hunt-graphql, hunt-shadow-api, hunt-spa-api | rota sem checar dono, `update(req.body)`, introspecção ligada; Supabase sem RLS |
| Requisições | hunt-ssrf, hunt-csrf, hunt-cors, hunt-open-redirect, hunt-websocket, hunt-grpc | fetch de URL do usuário, CORS refletido, `next=` sem validação |
| Arquivos | hunt-file-upload, hunt-lfi, hunt-xxe, hunt-deserialization | extensão sem magic bytes, path com entrada, `pickle`/`unserialize` |
| Fraude | hunt-business-logic, hunt-race-condition, hunt-fintech-graphql | preço vindo do cliente, float para dinheiro, saldo sem operação atômica, webhook sem assinatura |
| Borda | hunt-host-header, hunt-cache-poison, hunt-http-smuggling, hunt-subdomain, hunt-tls-network | URL a partir de `Host`, cache de rota privada, CNAME órfão |
| Código/CI | hunt-source-leak, token-scan, hunt-cicd, supply-chain-attack-recon | `.env` versionado, source maps, `pull_request_target`, actions sem SHA |
| Frameworks | hunt-nextjs, hunt-nodejs, hunt-laravel, hunt-springboot, hunt-aspnet | Server Action sem auth, `NEXT_PUBLIC_` secreto, `APP_DEBUG`, actuator |
| IA | hunt-llm-ai, hunt-rag-vector | ferramenta sem confirmação, RAG sem filtro de inquilino, segredo no prompt |
| Mobile | apk-redteam-pipeline, ios-redteam-pipeline, nexusup-reversa | chave no app, regra só no cliente |
| Contas/pessoas | offensive-osint, osint-methodology, hunt-ato | o que vaza publicamente, e-mail sem DMARC |
| Nuvem | cloud-iam-deep, hunt-cloud-misconfig, hunt-k8s | chave com permissão ampla, bucket público, IMDSv1 |
| Detecção | mid-engagement-ir-detection | o que logar e alertar |

   Se houver Supabase: `get_advisors` (security) + checar RLS em todas as tabelas.
   Se houver Vercel: env vars marcadas Sensitive, cabeçalhos em `vercel.json`/`next.config`.
5. **Teste das duas contas** (com autorização): conta A tenta ler/editar/apagar recursos da conta B.
6. **Plano de correção** — priorize: exposto publicamente > autorização/IDOR > auth > fraude >
   cabeçalhos/higiene. Para cada item: risco em 1 frase, prova, correção com código/config pronto,
   como confirmar.
7. **Entrega** — relatório no padrão `nexusup-identidade` (pode reaproveitar
   `../nexusup-pentest/relatorio-template.html`) e o checklist mestre do guia marcado.
   PDF: `python3 gerar-pdf.py arquivo.md saida.pdf`.

## Onde pegar credenciais
Tabela completa no guia (seção "Mapa de credenciais"). Resumo: painel do provedor (IP, root, console
VNC), `ssh-keygen -t ed25519` (chave SSH), Cloudflare → My Profile → API Tokens, GitHub → Developer
settings → Fine-grained tokens, Supabase → Project Settings → API Keys (`service_role` só no servidor),
Vercel → Settings → Environment Variables, gateway → Desenvolvedores → Credenciais + Webhook signing
secret. Tudo em gerenciador de senhas; rotação a cada 90 dias ou imediatamente em incidente.
