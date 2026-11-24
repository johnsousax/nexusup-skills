---
name: nexusup-identidade
description: Sistema de design e identidade visual da NexusUp (v1.1) — cores oficiais (Azul Nexus #1F5BFF, Grafite #1A1B1F, Papel, Névoa, Titânio, Azul Claro), tipografia Geist/Geist Mono, e todos os logotipos (company/horizontal/símbolo/vertical/wordmark em cor/negativo/preto/branco), favicons e app icons. Use SEMPRE que for criar qualquer coisa com a marca NexusUp — PDF, relatório, página web, artifact, app, ícone, post de rede social, e-mail, capa, documento. Os arquivos ficam em ~/nexusup-identidade. Aplique estes tokens e fontes exatos em vez de aproximar.
---

# NexusUp — Identidade Visual (v1.1)

Pacote completo em **`~/nexusup-identidade/`**: logos (SVG+PNG), favicons, app icons, fontes
Geist, redes sociais e o manual em PDF. Sempre que um trabalho for "da NexusUp", use isto.

## 1. Cores oficiais

| Nome | Hex | RGB | Uso |
|---|---|---|---|
| **Azul Nexus** | `#1F5BFF` | 31 91 255 | Cor da marca. Destaques, botões, links, acento. |
| **Grafite** | `#1A1B1F` | 26 27 31 | Texto principal e fundos escuros. |
| **Papel** | `#FAFAFC` | 250 250 252 | Fundo claro. |
| **Névoa** | `#F2F2F5` | 242 242 245 | Superfícies, cartões, divisórias. |
| **Titânio** | `#8C8A85` | 140 138 133 | Texto secundário / apoio. |
| **Azul Claro** | `#5B8CFF` | 91 140 255 | Logo e links **sobre fundo escuro**. |

Tokens prontos (cole no `:root`):

```css
:root{
  --azul-nexus:#1F5BFF; --grafite:#1A1B1F; --papel:#FAFAFC;
  --nevoa:#F2F2F5; --titanio:#8C8A85; --azul-claro:#5B8CFF;
}
/* no escuro, o azul vira o claro e o texto fica no papel */
```

Regra: azul é acento, não fundo de bloco grande de texto. Sobre Grafite, use Azul Claro para
links. CMYK é por conversão — validar prova com a gráfica antes de imprimir.

## 2. Tipografia — Geist

Fonte da marca: **Geist** (texto) e **Geist Mono** (código/números técnicos). SIL OFL, uso
comercial livre. Pesos presentes: Light, Regular, Medium, SemiBold, Bold.

- **Web / artifact:** carregar do Google Fonts —
  `<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">`
  e `font-family:"Geist",-apple-system,sans-serif;`
- **PDF / impresso / offline:** os arquivos estão em `~/nexusup-identidade/04-Fontes/`
  (`Geist-*.woff2`/`.ttf`, `GeistMono-*.woff2`). Use `@font-face` apontando para eles, ou
  copie os `.woff2` para o projeto.
- Títulos: Geist SemiBold/Bold, `letter-spacing:-.02em`. Corpo: Regular. Dados/código: Geist Mono.

```css
@font-face{font-family:"Geist";font-weight:400;src:url("fonts/Geist-Regular.woff2") format("woff2");}
@font-face{font-family:"Geist";font-weight:600;src:url("fonts/Geist-SemiBold.woff2") format("woff2");}
@font-face{font-family:"Geist";font-weight:700;src:url("fonts/Geist-Bold.woff2") format("woff2");}
@font-face{font-family:"Geist Mono";font-weight:400;src:url("fonts/GeistMono-Regular.woff2") format("woff2");}
```

## 3. Logotipos

Cinco formatos, cada um em quatro variantes de cor. Arquivos em
`~/nexusup-identidade/01-Logotipos/{SVG,PNG}/nexusup-<formato>-<variante>.{svg,png}`.

- **Formatos:** `company` (logo + "Company"), `horizontal`, `vertical`, `simbolo` (só o ícone
  N), `wordmark` (só o texto).
- **Variante por fundo:**
  - `-cor` → fundo **claro** (Papel/Névoa/branco).
  - `-negativo` → fundo **escuro** (Grafite).
  - `-branco` → sobre **azul** ou **fotos**.
  - `-preto` → **uma cor** (preto/branco, carimbo, fax, gravação).
- Prefira **SVG** (vetor, textos em curvas). Dê respiro em volta (área livre ≥ altura do
  símbolo) e não use abaixo de ~24 px de altura (use o `simbolo` nesses casos).

O símbolo (N que vira seta pra cima) — pode ser colado inline em qualquer documento:

```html
<svg viewBox="0 0 82 94" width="40" height="46" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(-19 -9)">
    <path d="M28 94V34L68 80" fill="none" stroke="#1A1B1F" stroke-width="18" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M92 94V18" fill="none" stroke="#1F5BFF" stroke-width="18" stroke-linecap="round"/>
  </g>
</svg>
```
No escuro, troque o stroke `#1A1B1F` por `#FFFFFF` (ou use o arquivo `-negativo`).

## 4. Ícones e favicon

`~/nexusup-identidade/02-Icones-e-favicon/`: `nexusup-app-icon-{1024,512,180}.png` (+ versão
`-claro` e `-quadrado`), `favicon-{16,32,48}.png`, `android-chrome-192.png`, `nexusup-favicon.svg`.
Para artifacts/HTML, o `icon` do `<title>`/favicon é o símbolo N.

## 5. Receita rápida (base de qualquer peça NexusUp)

```html
<style>
:root{--azul-nexus:#1F5BFF;--grafite:#1A1B1F;--papel:#FAFAFC;--nevoa:#F2F2F5;--titanio:#8C8A85;--azul-claro:#5B8CFF;}
body{font-family:"Geist",-apple-system,sans-serif;color:var(--grafite);background:var(--papel);line-height:1.55;}
h1,h2,h3{font-weight:600;letter-spacing:-.02em;}
a{color:var(--azul-nexus);} .mono{font-family:"Geist Mono",monospace;}
.btn{background:var(--azul-nexus);color:#fff;border-radius:10px;padding:10px 16px;font-weight:600;}
@media(prefers-color-scheme:dark){:root:not([data-theme="light"]){--grafite:#FAFAFC;--papel:#1A1B1F;--nevoa:#242529;}
  :root:not([data-theme="light"]) a{color:var(--azul-claro);}}
</style>
```

**PDF** (como no doc do sistema): montar HTML com estes tokens + Geist, depois
`"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf=saida.pdf file://<html>`.

## 6. Nunca

- Não esticar, girar, recolorir (fora das variantes) nem trocar a fonte do logo.
- Não pôr o logo `-cor` sobre fundo escuro nem o `-negativo` sobre claro (contraste some).
- Não usar azul como fundo de blocos longos de texto.
- Não aproximar as cores "de olho" — use os hex oficiais acima.
