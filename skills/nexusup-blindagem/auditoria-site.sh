#!/usr/bin/env bash
# NexusUp Blindagem — auditoria PASSIVA de um site SEU (ou autorizado por escrito).
# Só faz requisições GET comuns, como um navegador. Uso: bash auditoria-site.sh seudominio.com.br
set -u
D="${1:?uso: bash auditoria-site.sh seudominio.com.br}"; D="${D#https://}"; D="${D#http://}"; D="${D%%/*}"
U="https://$D"
ok(){ printf '\033[32m[OK]\033[0m     %s\n' "$*"; }
al(){ printf '\033[31m[ALERTA]\033[0m %s\n' "$*"; ALERTAS=$((ALERTAS+1)); }
inf(){ printf '\033[34m[INFO]\033[0m   %s\n' "$*"; }
sec(){ printf '\n\033[1m== %s ==\033[0m\n' "$*"; }
ALERTAS=0
UA="NexusUp-Blindagem/1.0"

sec "HTTPS"
C=$(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' -A "$UA" "http://$D/" --max-time 15)
echo "$C" | grep -q 'https://' && ok "HTTP redireciona para HTTPS" || al "HTTP não redireciona para HTTPS ($C)"
for v in tlsv1.0 tlsv1.1; do
  curl -s -o /dev/null --"$v" --tls-max "${v#tlsv}" "$U" --max-time 10 2>/dev/null && al "Aceita $v (desative)" || ok "Recusa $v"
done
EXP=$(echo | openssl s_client -servername "$D" -connect "$D:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
[ -n "$EXP" ] && inf "Certificado vence em: $EXP"

sec "Cabeçalhos de segurança"
H=$(curl -sIL -A "$UA" "$U" --max-time 15 | tr -d '\r' | awk 'BEGIN{RS="";ORS="\n\n"}{b=$0}END{print b}')
chk(){ echo "$H" | grep -qi "^$1:" && ok "$1: $(echo "$H" | grep -i "^$1:" | head -1 | cut -d: -f2- | cut -c1-80)" || al "Falta $1"; }
chk Strict-Transport-Security; chk Content-Security-Policy; chk X-Content-Type-Options
chk Referrer-Policy; chk Permissions-Policy
echo "$H" | grep -qiE '^x-frame-options:|frame-ancestors' && ok "Proteção contra clickjacking" || al "Falta X-Frame-Options ou CSP frame-ancestors"
echo "$H" | grep -qiE "^content-security-policy:.*unsafe-(inline|eval)" && al "CSP usa unsafe-inline/unsafe-eval"
echo "$H" | grep -iE '^(server|x-powered-by|x-aspnet-version):' | while read -r l; do inf "Revela tecnologia: $l"; done

sec "Cookies"
echo "$H" | grep -i '^set-cookie:' | while read -r c; do
  n=$(echo "$c" | cut -d: -f2- | cut -d= -f1 | xargs)
  f=""; echo "$c" | grep -qi 'secure' || f="$f sem-Secure"; echo "$c" | grep -qi 'httponly' || f="$f sem-HttpOnly"
  echo "$c" | grep -qi 'samesite' || f="$f sem-SameSite"
  [ -z "$f" ] && ok "Cookie $n com flags corretas" || inf "Cookie $n:$f (se for de sessão, corrija)"
done

sec "Arquivos que não deveriam estar públicos"
HOME_SZ=$(curl -sL -A "$UA" "$U/" --max-time 15 | wc -c | tr -d ' ')
SPA_SZ=$(curl -sL -A "$UA" "$U/nexusup-rota-inexistente-$$" --max-time 15 | wc -c | tr -d ' ')
for p in .env .env.local .env.production .git/HEAD .git/config .svn/entries .DS_Store backup.zip backup.sql db.sql dump.sql \
         wp-config.php.bak config.php.bak phpinfo.php server-status actuator actuator/env actuator/heapdump \
         .vscode/sftp.json docker-compose.yml package.json composer.json web.config trace.axd elmah.axd \
         api/swagger.json swagger-ui.html openapi.json graphql .well-known/security.txt; do
  r=$(curl -s -o /tmp/nexus_bl_$$ -w '%{http_code}' -A "$UA" "$U/$p" --max-time 10)
  sz=$(wc -c < /tmp/nexus_bl_$$ 2>/dev/null || echo 0)
  if [ "$p" = ".well-known/security.txt" ]; then
    [ "$r" = "200" ] && ok "security.txt publicado" || inf "Sem /.well-known/security.txt (recomendado)"; continue; fi
  if [ "$r" = "200" ] && [ "$sz" -gt 0 ]; then
    if [ "$sz" -eq "$HOME_SZ" ] || [ "$sz" -eq "$SPA_SZ" ]; then :   # fallback de SPA: não é o arquivo
    elif grep -qiE '<!doctype html|<html' /tmp/nexus_bl_$$ && ! echo "$p" | grep -qE 'swagger|graphql'; then
      inf "/$p → 200 mas é página HTML (provável rota SPA, confira)"
    else al "/$p exposto (HTTP 200, ${sz} bytes)"; fi
  fi
done; rm -f /tmp/nexus_bl_$$
JS=$(curl -s -A "$UA" "$U" --max-time 15 | grep -oE 'src="[^"]+\.js"' | head -5 | cut -d'"' -f2)
for j in $JS; do
  case "$j" in http*) ju="$j";; //*) ju="https:$j";; /*) ju="$U$j";; *) ju="$U/$j";; esac
  curl -s -o /dev/null -w '%{http_code}' "$ju.map" --max-time 10 | grep -q 200 && al "Source map público: $ju.map"
  curl -s "$ju" --max-time 15 | grep -oE '(sk_live_[A-Za-z0-9]{10,}|AKIA[0-9A-Z]{16}|service_role|-----BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{30,}|AIza[0-9A-Za-z_-]{35})' | sort -u | while read -r s; do al "Possível segredo no JS $ju: ${s:0:12}…"; done
done

sec "CORS"
A=$(curl -sI -A "$UA" -H 'Origin: https://evil.example' "$U" --max-time 10 | tr -d '\r' | grep -i '^access-control-allow-')
echo "$A" | grep -qi 'evil.example' && al "CORS reflete origem arbitrária: $A" || ok "CORS não reflete origem arbitrária na página inicial"

sec "DNS e e-mail"
if command -v dig >/dev/null; then
  case "$D" in *.com.br|*.net.br|*.org.br|*.co.uk) B=$(echo "$D" | awk -F. '{print $(NF-2)"."$(NF-1)"."$NF}');;
    *) B=$(echo "$D" | awk -F. '{print $(NF-1)"."$NF}');; esac
  [ "$B" != "$D" ] && inf "E-mail/DNS checados no domínio raiz: $B"
  dig +short TXT "$B" | grep -q 'v=spf1' && ok "SPF: $(dig +short TXT "$B" | grep spf1 | head -1)" || al "Sem SPF"
  dig +short TXT "_dmarc.$B" | grep -q 'v=DMARC1' && { dig +short TXT "_dmarc.$B" | grep -q 'p=reject\|p=quarantine' && ok "DMARC com política" || al "DMARC p=none (use quarantine/reject)"; } || al "Sem DMARC"
  dig +short CAA "$B" | grep -q issue && ok "Registro CAA presente" || inf "Sem registro CAA (recomendado)"
  inf "IP(s): $(dig +short A "$D" | tr '\n' ' ')"
fi

sec "Resultado"
[ "$ALERTAS" -eq 0 ] && ok "Nenhum alerta passivo. Próximo: securityheaders.com, ssllabs.com e teste de duas contas (IDOR)." \
  || al "$ALERTAS alerta(s). Corrija pelo guia NexusUp-Blindagem."
