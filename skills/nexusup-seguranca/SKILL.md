---
name: nexusup-seguranca
description: Operar a plataforma NexusUp Segurança (pentest autônomo, repo nexusup-seguranca / ~/ARTEX) num trabalho de análise de segurança CONTRATADO e AUTORIZADO — fechar escopo e autorização assinada, subir a plataforma, cadastrar só os alvos autorizados, rodar o teste autônomo, revisar os achados com evidência e gerar o relatório. Use quando o usuário for conduzir um pentest/análise de falhas para um cliente, preparar a autorização, rodar o ARTEX/NexusUp Segurança, ou montar o relatório. NÃO use para tocar sistema sem autorização por escrito.
---

# NexusUp Segurança — operação de um pentest autorizado

Plataforma: `~/ARTEX` (instalação de trabalho, binário em `dist/`) e o repositório
`github.com/johnsousax/nexusup-seguranca` (fonte, AGPL-3.0). Console em `http://localhost:8787`.

## Regra zero — autorização primeiro

**Nunca** rode um módulo ativo contra um alvo sem autorização por escrito.

1. Antes de qualquer coisa, preencha e colha a assinatura do cliente no modelo
   `modelos/autorizacao-pentest.md` (do repo). Ele fixa: escopo (o que pode), fora de
   escopo (o que não pode), janela de tempo e contatos de emergência.
2. Se o usuário pedir para testar algo que não está no escopo assinado, **pare e avise** —
   não prossiga. Testar sistema de terceiro sem autorização é crime (art. 154-A CP).
3. Para treino/demonstração sem cliente: só laboratórios próprios (DVWA, OWASP Juice Shop,
   HackTheBox, máquinas do próprio usuário).

## Subir a plataforma (no Mac do usuário)

O classificador não deixa o Claude executar o Postgres portátil nem o binário `artex`.
Peça ao usuário para rodar, com prefixo `!`:

```
! cd ~/ARTEX/dist/artex-0.6.0-darwin-amd64 && ./pg-start.sh && ./artex
```

Depois: abrir `http://localhost:8787`, pegar o `Setup token` no log, configurar o provedor
de LLM na UI. A interface abre em Português.

## Fluxo do trabalho

1. **Escopo** — cadastrar a empresa e os ativos no console. Só os alvos do documento
   assinado. Use escopo com wildcard quando autorizado (ex.: `*.cliente.com.br`).
2. **Rodar** — iniciar o teste autônomo (planejador + executores). Acompanhar pelo grafo
   de exploração e pelos logs.
3. **Revisar** — cada achado vem amarrado ao ativo e à captura de tráfego que o provam.
   Conferir severidade (CVSS) e descartar falso-positivo.
4. **Relatório** — gerar o relatório com evidência (`report/`), em Português, e entregar
   ao cliente. Acompanhar a correção.

## Lado defensivo

`detections/` traz assinaturas Sigma/Suricata. Servem para o cliente **detectar** esse tipo
de ataque depois — é um entregável extra de valor (não só "achei a falha", mas "como você
percebe se alguém tentar de novo").

## Limites e segurança

- Nada de ações destrutivas (apagar dados, DoS) sem pedido explícito por escrito.
- Dados pessoais (LGPD): apenas **prova de acesso** (1 registro mascarado), nunca cópia em massa.
- Ao fim da janela: remover qualquer artefato instalado, não manter acesso.
- Vulnerabilidades são confidenciais do cliente.

## Referências no repo

- `README.md` — visão geral e provenance (AGPL, créditos aos upstreams).
- `modelos/autorizacao-pentest.md` — o documento que torna o trabalho legal.
- `docs/README.upstream.md` — instalação e configuração detalhadas.
