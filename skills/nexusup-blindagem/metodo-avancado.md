# Método avançado (vindo do nexusup-seguranca / ARTEX)

Complementa o fluxo da `SKILL.md` com o que a plataforma autônoma faz e que dá para fazer
**sem rodar o ARTEX**, só com o Claude Code. Fontes: skills `codeaudit`, `api-security` e
`api-recon` do repositório `johnsousax/nexusup-seguranca` (a `api-security` é adaptada de
zhaoxuya520/reverse-skill, MIT).

## 1. Portões de qualidade (antes de reportar qualquer achado)
- **Alcançável:** a entrada vem de alguém de fora? Mostre o caminho entrada → ponto perigoso.
- **Sem trava no meio:** procure ativamente a validação, o gatilho ou a política que bloqueia.
  Se existir, o achado cai para "mitigado/defesa em camadas".
- **Prova:** controle de acesso só existe se provado com **segunda conta ou papel**.
- **Impacto medido:** o que exatamente vaza ou muda, em números (linhas, valores).
- **Contra-argumento:** escreva a melhor razão para NÃO ser falha. Se ela vencer, descarte.

## 2. Auditoria de código (codeaudit)
1. Liste **toda entrada controlável**: rotas, `req.body/query/headers`, webhooks, mensagens de
   WhatsApp/Telegram, resultados de apps MCP/IA, arquivos enviados.
2. Siga cada uma **para frente** até os pontos perigosos: SQL, shell, `fetch` (SSRF), caminho de
   arquivo, render HTML, gravação com service_role, chamada de pagamento.
3. Só código de produção. Pule testes, build, vendor e gerado; anote a fronteira da dependência.
4. Funções com **service_role** (edge functions Supabase, rotas de servidor) ignoram o RLS:
   confira em cada ação `auth.getUser(token)` **e** a permissão por empresa/papel.
5. Procure **fraude interna**: ações de "admin" liberadas para papéis amplos, sem trilha de auditoria.

## 3. Isolamento entre clientes no Supabase (IDOR sem criar conta)
Rode com `execute_sql`, sempre em transação desfeita. Arquivo pronto: `teste-isolamento.sql`.
- Papel `authenticated` com um `sub` aleatório (usuário sem empresa) → todas as tabelas do app
  devem dar **0** (exceto catálogos públicos de propósito).
- Papel `anon` → deve dar **permission denied** ou 0.
- Para provar entre duas empresas reais: use o `sub` de um membro da empresa A e conte linhas
  com `empresa_id` da empresa B (deve ser 0). Não leia os dados: só `count(*)`.

## 4. Fraude de lógica no banco
Leia `pg_policies` (UPDATE/INSERT/ALL) e os gatilhos `BEFORE UPDATE` das tabelas de
empresa, membros, cobrança e plano. Pergunte: o usuário consegue mudar o **próprio** plano, papel,
empresa, status de cobrança, preço? Cada "sim" sem gatilho de proteção é achado.

## 5. Superfície (api-recon, passivo)
- Funções: `list_edge_functions` (verify_jwt false = a função tem que checar sozinha).
- RPC expostas: Security Advisor (`anon_security_definer_function_executable`) e depois ler o
  corpo de cada função (muitas têm trava interna → mitigado).
- Front: REA `analyze_web_bundle` (neste Mac, pode estourar o tempo; use também o grep de
  segredos do `auditoria-site.sh`).
- App desktop/Electron: REA `audit_release_exposure` + `inspect_electron_fuses`.

## 6. Quando usar o ARTEX de verdade
Só para teste **ativo** (força bruta, SQLi, varredura), com autorização escrita e, de preferência,
contra **homologação**. O usuário liga (`./pg-start.sh && ./artex`, porta 127.0.0.1:8787). Use o
modelo `modelos/autorizacao-pentest.md` do nexusup-seguranca e as assinaturas de detecção
(`detections/sigma`, `detections/suricata`) para o cliente ver o ataque nos logs dele.
