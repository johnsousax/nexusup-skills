#!/usr/bin/env python3
"""Converte um Markdown NexusUp em PDF com a identidade visual (Geist, Azul Nexus, Grafite).
Uso: python3 gerar-pdf.py entrada.md saida.pdf
Sem dependências externas: conversor Markdown mínimo + Chrome headless.
Front matter opcional (--- titulo/subtitulo/versao/data/classificacao ---) vira a capa."""
import html, os, re, subprocess, sys, tempfile, pathlib

AQUI = pathlib.Path(__file__).resolve().parent
FONTES = [pathlib.Path.home() / "nexusup-identidade/04-Fontes", AQUI / "fonts"]
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

SIMBOLO = lambda cor: f'''<svg viewBox="0 0 82 94" width="38" height="44"><g transform="translate(-19 -9)">
<path d="M28 94V34L68 80" fill="none" stroke="{cor}" stroke-width="18" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M92 94V18" fill="none" stroke="#1F5BFF" stroke-width="18" stroke-linecap="round"/></g></svg>'''

def inline(t):
    partes = re.split(r"(`[^`]+`)", t)
    out = []
    for p in partes:
        if p.startswith("`") and p.endswith("`") and len(p) > 1:
            out.append("<code>" + html.escape(p[1:-1]) + "</code>"); continue
        p = html.escape(p, quote=False)
        p = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", p)
        p = re.sub(r"(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])", r"<i>\1</i>", p)
        p = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', p)
        out.append(p)
    return "".join(out)

def converter(md):
    meta, corpo = {}, md
    m = re.match(r"^---\n(.*?)\n---\n", md, re.S)
    if m:
        for l in m.group(1).splitlines():
            if ":" in l:
                k, v = l.split(":", 1); meta[k.strip()] = v.strip()
        corpo = md[m.end():]
    linhas, i, h, secoes = corpo.splitlines(), 0, [], []
    while i < len(linhas):
        l = linhas[i]
        if l.startswith("```"):
            j = i + 1; bloco = []
            while j < len(linhas) and not linhas[j].startswith("```"):
                bloco.append(linhas[j]); j += 1
            h.append("<pre>" + html.escape("\n".join(bloco)) + "</pre>"); i = j + 1; continue
        mh = re.match(r"^(#{1,3}) (.*)", l)
        if mh:
            n, txt = len(mh.group(1)), mh.group(2)
            if n == 1:
                secoes.append(txt); sid = f"s{len(secoes)}"
                h.append(f'<h1 id="{sid}"><span class="num">{len(secoes):02d}</span>{inline(txt)}</h1>')
            else:
                h.append(f"<h{n}>{inline(txt)}</h{n}>")
            i += 1; continue
        if l.startswith("|"):
            rows = []
            while i < len(linhas) and linhas[i].startswith("|"):
                rows.append([c.strip() for c in linhas[i].strip().strip("|").split("|")]); i += 1
            t = "<table><thead><tr>" + "".join(f"<th>{inline(c)}</th>" for c in rows[0]) + "</tr></thead><tbody>"
            for r in rows[2:]:
                t += "<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>"
            h.append(t + "</tbody></table>"); continue
        if l.startswith(">"):
            q = []
            while i < len(linhas) and linhas[i].startswith(">"):
                q.append(linhas[i].lstrip("> ").rstrip()); i += 1
            h.append('<div class="box">' + inline(" ".join(q)) + "</div>"); continue
        if re.match(r"^(\s*)([-*]|\d+\.) ", l):
            ordenada = bool(re.match(r"^\s*\d+\. ", l)); itens = []
            while i < len(linhas) and re.match(r"^(\s*)([-*]|\d+\.) ", linhas[i]):
                itens.append(re.sub(r"^\s*([-*]|\d+\.) ", "", linhas[i])); i += 1
            tag = "ol" if ordenada else "ul"
            cls = ' class="check"' if all(x.startswith("[ ]") or x.startswith("[x]") for x in itens) else ""
            lis = "".join("<li>" + (('<span class="cb"></span>' + inline(x[3:].strip())) if cls else inline(x)) + "</li>" for x in itens)
            h.append(f"<{tag}{cls}>{lis}</{tag}>"); continue
        if not l.strip():
            i += 1; continue
        par = [l]; i += 1
        while i < len(linhas) and linhas[i].strip() and not re.match(r"^(#|\||>|```|\s*([-*]|\d+\.) )", linhas[i]):
            par.append(linhas[i]); i += 1
        txt = " ".join(par)
        cls = ' class="fim"' if txt.startswith("*") and txt.endswith("*") and not txt.startswith("**") else ""
        h.append(f"<p{cls}>{inline(txt)}</p>")
    return meta, secoes, "\n".join(h)

def fontes_css():
    for d in FONTES:
        if (d / "Geist-Regular.woff2").exists():
            css = ""
            for peso, nome in [(300, "Light"), (400, "Regular"), (500, "Medium"), (600, "SemiBold"), (700, "Bold")]:
                f = d / f"Geist-{nome}.woff2"
                if f.exists():
                    css += f'@font-face{{font-family:"Geist";font-weight:{peso};src:url("{f.as_uri()}")}}\n'
            for peso, nome in [(400, "Regular"), (500, "Medium")]:
                f = d / f"GeistMono-{nome}.woff2"
                if f.exists():
                    css += f'@font-face{{font-family:"Geist Mono";font-weight:{peso};src:url("{f.as_uri()}")}}\n'
            return css
    return '@import url("https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap");'

CSS = """
:root{--azul:#1F5BFF;--grafite:#1A1B1F;--papel:#FAFAFC;--nevoa:#F2F2F5;--titanio:#8C8A85;--azulclaro:#5B8CFF;--linha:#E4E5EB}
*{box-sizing:border-box}html,body{margin:0;padding:0}
body{font-family:"Geist",-apple-system,Arial,sans-serif;color:var(--grafite);font-size:10.6px;line-height:1.58;-webkit-font-smoothing:antialiased}
@page{size:A4;margin:15mm 15mm 16mm}@page:first{margin:0}
.capa{width:210mm;height:297mm;background:var(--grafite);color:#fff;padding:22mm 20mm;display:flex;flex-direction:column;page-break-after:always;position:relative;overflow:hidden}
.capa .marca{display:flex;align-items:center;gap:12px;font-weight:600;font-size:14px;letter-spacing:-.01em}
.capa .tag{margin-top:auto;font-family:"Geist Mono",monospace;font-size:10px;color:var(--azulclaro);letter-spacing:.14em;text-transform:uppercase}
.capa h1{font-size:58px;line-height:1;letter-spacing:-.045em;font-weight:700;margin:14px 0 18px}
.capa h1 span{color:var(--azulclaro)}
.capa .sub{font-size:17px;line-height:1.4;color:#C9CAD2;max-width:150mm;font-weight:300}
.capa .rodape{margin-top:26mm;border-top:1px solid #34353B;padding-top:12px;display:flex;justify-content:space-between;font-size:10px;color:#9C9BA0;font-family:"Geist Mono",monospace}
.capa .camadas{position:absolute;right:-30mm;top:40mm;width:120mm;opacity:.9}
.indice{page-break-after:always}
.indice h2{font-size:26px;letter-spacing:-.03em;border:0;margin:0 0 18px}
.indice ol{list-style:none;padding:0;margin:0;columns:1}
.indice li{display:flex;gap:14px;align-items:baseline;padding:9px 0;border-bottom:1px solid var(--linha);font-size:13px;font-weight:500}
.indice li span{font-family:"Geist Mono",monospace;color:var(--azul);font-size:11px;width:22px}
h1{font-size:24px;font-weight:700;letter-spacing:-.03em;margin:0 0 14px;padding-top:2px;page-break-before:always;display:flex;align-items:baseline;gap:12px}
h1 .num{font-family:"Geist Mono",monospace;font-size:12px;color:#fff;background:var(--azul);border-radius:6px;padding:3px 7px;letter-spacing:0;position:relative;top:-4px}
h2{font-size:15px;font-weight:600;letter-spacing:-.02em;margin:20px 0 8px;padding-bottom:5px;border-bottom:2px solid var(--linha);page-break-after:avoid}
h3{font-size:12.5px;font-weight:600;margin:14px 0 6px;page-break-after:avoid}
p{margin:0 0 8px}b{font-weight:600}a{color:var(--azul);text-decoration:none}
code{font-family:"Geist Mono",monospace;background:var(--nevoa);border-radius:4px;padding:.5px 4px;font-size:9.6px;border:1px solid var(--linha)}
pre{font-family:"Geist Mono",monospace;background:var(--grafite);color:#E6E7EC;border-radius:8px;padding:11px 13px;font-size:9.2px;line-height:1.5;white-space:pre-wrap;word-break:break-word;page-break-inside:avoid;margin:6px 0 12px}
table{width:100%;border-collapse:collapse;margin:6px 0 14px;font-size:9.6px;page-break-inside:auto}
tr{page-break-inside:avoid}
th{background:var(--nevoa);text-align:left;font-size:8.6px;text-transform:uppercase;letter-spacing:.06em;color:#5E5D59;font-weight:600;padding:7px 8px;border-bottom:1px solid var(--linha)}
td{padding:7px 8px;border-bottom:1px solid var(--linha);vertical-align:top}
td:first-child{font-weight:500}
ul,ol{margin:0 0 10px;padding-left:18px}li{margin:3px 0}
ul.check{list-style:none;padding-left:2px}ul.check li{display:flex;gap:8px;align-items:flex-start}
.cb{flex:none;width:11px;height:11px;border:1.5px solid var(--azul);border-radius:3px;margin-top:2px}
.box{background:#EEF3FF;border-left:3px solid var(--azul);border-radius:6px;padding:10px 13px;margin:10px 0 12px;page-break-inside:avoid}
p.fim{margin-top:28px;text-align:center;color:var(--titanio);font-size:10px}
"""

CAMADAS_SVG = "".join(
    f'<rect x="{i*9}" y="{i*26}" width="{360-i*18}" height="20" rx="10" fill="{c}" opacity="{0.95-i*0.08}"/>'
    for i, c in enumerate(["#1F5BFF", "#3069FF", "#4277FF", "#5B8CFF", "#7AA2FF", "#9AB8FF", "#B9CEFF", "#D6E2FF"]))

def main():
    if len(sys.argv) < 3:
        sys.exit("uso: python3 gerar-pdf.py entrada.md saida.pdf")
    md = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
    saida = pathlib.Path(sys.argv[2]).resolve()
    meta, secoes, corpo = converter(md)
    titulo = meta.get("titulo", "NexusUp")
    pal = titulo.split(" ", 1)
    titulo_html = f"{html.escape(pal[0])}<br><span>{html.escape(pal[1])}</span>" if len(pal) > 1 else html.escape(titulo)
    capa = f"""<section class="capa">
<div class="marca">{SIMBOLO('#FFFFFF')}<span>NexusUp&nbsp;Segurança</span></div>
<svg class="camadas" viewBox="0 0 360 210">{CAMADAS_SVG}</svg>
<div class="tag">{html.escape(meta.get('tag','Guia de defesa'))} · {html.escape(meta.get('classificacao',''))}</div>
<h1>{titulo_html}</h1>
<div class="sub">{html.escape(meta.get('subtitulo',''))}</div>
<div class="rodape"><span>NexusUp Company</span><span>v{html.escape(meta.get('versao','1.0'))} · {html.escape(meta.get('data',''))}</span></div>
</section>"""
    indice = '<section class="indice"><h2>Conteúdo</h2><ol>' + "".join(
        f'<li><span>{i+1:02d}</span><a href="#s{i+1}" style="color:inherit">{inline(s)}</a></li>' for i, s in enumerate(secoes)) + "</ol></section>"
    doc = f"""<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>{html.escape(titulo)} — NexusUp</title>
<style>{fontes_css()}{CSS}</style></head><body>{capa}{indice}{corpo}</body></html>"""
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as f:
        f.write(doc); tmp = f.name
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--no-pdf-header-footer", "--allow-file-access-from-files",
                    f"--print-to-pdf={saida}", pathlib.Path(tmp).as_uri()], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=180)
    if os.environ.get("MANTER_HTML"):
        print("HTML:", tmp)
    else:
        os.unlink(tmp)
    print("PDF:", saida)

if __name__ == "__main__":
    main()
