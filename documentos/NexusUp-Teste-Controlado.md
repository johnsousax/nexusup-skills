---
titulo: Teste Controlado
subtitulo: Como testar a segurança de um sistema que já está no ar, com clientes usando, sem causar problema
versao: 1.0
data: 25/11/2026
classificacao: Público
tag: Guia de método
---

# Por que testar numa cópia

Imagine que o seu sistema é uma **loja aberta, cheia de clientes**. Para saber se as fechaduras aguentam, você não chama um chaveiro para forçar a porta com a loja lotada. Você monta uma **loja igual nos fundos**, sem clientes, e testa lá.

Um teste de segurança de verdade (pentest ativo) **força** o sistema: tenta milhares de senhas, envia dados estranhos, cria e apaga registros, faz muitas requisições por segundo. Na produção, isso pode:

- **Travar contas de clientes reais** (bloqueio por senha errada).
- **Sujar o banco** com cadastros, pedidos e lançamentos de teste.
- **Disparar e-mails, WhatsApp ou cobranças** para pessoas reais.
- **Derrubar ou deixar lento** o sistema (e o firewall pode bloquear o seu próprio IP).
- **Gerar custos** em APIs pagas (IA, SMS, gateway).

> **Regra de ouro:** produção recebe só **teste passivo** (ler cabeçalhos, conferir configuração, revisar código). **Teste ativo vai sempre para a cópia.**

## Passivo × ativo

| | Teste passivo | Teste ativo (ataque controlado) |
|---|---|---|
| O que faz | Lê e observa, como um visitante comum | Força o sistema como um invasor faria |
| Exemplos | Cabeçalhos, TLS, DNS, revisão de código, configuração do banco, Security Advisor | Força bruta, injeção, testes de autorização com contas, varredura automatizada, ARTEX |
| Onde | Pode ser na produção | **Só na cópia de teste (homologação)** |
| Risco | Praticamente zero | Alto se feito em produção |

# Os 6 passos do teste controlado

## 1. Autorização por escrito

Antes de qualquer coisa, um documento assinado pelo dono do sistema dizendo:

- **O que** pode ser testado (endereços exatos da cópia).
- **O que NÃO pode** (produção, sistemas de terceiros, e-mails e telefones reais).
- **Quando** (janela de datas e horários).
- **Quem** testa e quem é o contato de emergência.

Mesmo quando o sistema é seu, registre isso. Serve de prova e evita "testar sem querer" o que não devia. A NexusUp usa o modelo `modelos/autorizacao-pentest.md` do repositório `nexusup-seguranca`.

## 2. Monte a cópia (homologação)

A cópia precisa ser **igual na estrutura** e **separada nos dados e nas chaves**.

| Peça | Como copiar | Cuidado |
|---|---|---|
| **Banco Supabase** | *Branches → Create branch* (banco isolado com as mesmas tabelas, políticas RLS e funções) | Sem dados de clientes reais. Se precisar de massa de dados, use dados **falsos** |
| **Site na Vercel** | Deploy de **Preview** apontando para o branch (variáveis de ambiente do Preview) | Confira se o Preview **não** usa as chaves de produção |
| **Servidor / VPS** | Segundo serviço no Easypanel/Docker, ou uma VPS pequena só de teste | Volume e banco próprios |
| **Pagamento** | **Modo sandbox** do gateway (Asaas sandbox, Stripe test mode, Mercado Pago teste) | Nunca a chave de produção |
| **E-mail / WhatsApp** | Desligar ou apontar para caixas e números de teste | Evita mandar mensagem para cliente real |
| **IA / APIs pagas** | Chave separada **com limite de gasto baixo** | Um teste automatizado gasta rápido |

## 3. Contas e dados de teste

Crie **pelo menos duas empresas e três contas** na cópia: admin da empresa A, colaborador da empresa A e admin da empresa B. É com elas que se prova se uma empresa consegue ver os dados da outra (IDOR). Esse é o teste mais importante de qualquer sistema com vários clientes.

Use e-mails do tipo `teste-a@seudominio.com.br` e anote tudo num lugar só.

## 4. Escopo travado na ferramenta

Na ferramenta de teste (ARTEX, Burp, ZAP), cadastre **somente** os endereços da cópia:

- ✅ `https://meu-app-git-teste.vercel.app` e o endereço do branch do Supabase.
- ❌ O domínio de produção, o banco principal, serviços de terceiros (gateway, Meta, Google).

No **ARTEX** isso é o **Escopo** da tarefa. Ele recusa alvos fora da lista. Rode o ARTEX **no seu computador** (`127.0.0.1:8787`), com um modelo de IA configurado e limite de gasto.

## 5. Durante o teste

- **Avise** quem cuida do sistema e anote o horário de início e fim.
- **Acompanhe os logs** da cópia (Supabase → Logs, Vercel → Logs). É ótimo para ver o que um ataque real deixaria de rastro e criar alertas depois.
- **Botão de parar:** saiba como pausar a tarefa e desligar a ferramenta na hora.
- Se algo **vazar para fora do escopo**, pare, registre e avise.

## 6. Depois do teste

1. **Valide cada achado:** reproduza, confirme o impacto e descarte falsos positivos (portões de qualidade da skill `nexusup-blindagem`).
2. **Corrija na cópia primeiro**, teste de novo e só então leve a correção para a produção.
3. **Limpe tudo:** apague o branch do banco, o Preview, as contas de teste e as chaves temporárias (elas custam e viram porta aberta se esquecidas).
4. **Relatório:** achado, risco, prova, correção e como confirmar, no padrão NexusUp.

# Checklist rápido

- [ ] Autorização por escrito com escopo, janela e contato
- [ ] Banco de teste separado (branch) sem dados reais
- [ ] Site de teste (Preview) com chaves de teste
- [ ] Pagamento em sandbox. E-mail e WhatsApp desligados ou de teste
- [ ] Chaves de IA/API com limite de gasto
- [ ] Duas empresas e três contas de teste criadas
- [ ] Escopo da ferramenta só com os endereços da cópia
- [ ] Logs da cópia abertos durante o teste
- [ ] Achados validados, corrigidos na cópia e depois na produção
- [ ] Cópia, contas e chaves de teste apagadas no final

# O que pode ser feito direto na produção

Sem risco para os usuários, e é por aqui que a NexusUp começa:

- `auditoria-site.sh` (cabeçalhos, TLS, arquivos expostos, segredos no JavaScript, SPF/DMARC).
- Supabase **Security Advisor** e leitura das políticas RLS e funções.
- Teste de isolamento **simulado** no banco, em transação desfeita (`teste-isolamento.sql`), sem criar conta nem gravar nada.
- Revisão de código (método codeaudit) e varredura de segredos e dependências.
- REA no app ou no build entregue (fuses do Electron, source maps, segredos embutidos).

*NexusUp Company · Segurança com provas na mão.*
