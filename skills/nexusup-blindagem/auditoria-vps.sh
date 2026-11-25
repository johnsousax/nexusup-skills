#!/usr/bin/env bash
# NexusUp Blindagem — auditoria SOMENTE LEITURA de uma VPS Linux (Ubuntu/Debian).
# Não altera nada. Rode dentro da VPS:  sudo bash auditoria-vps.sh
# Saída: [OK] / [ALERTA] / [INFO] para cada item do checklist da Blindagem.

set -u
ok(){ printf '\033[32m[OK]\033[0m     %s\n' "$*"; }
al(){ printf '\033[31m[ALERTA]\033[0m %s\n' "$*"; ALERTAS=$((ALERTAS+1)); }
inf(){ printf '\033[34m[INFO]\033[0m   %s\n' "$*"; }
sec(){ printf '\n\033[1m== %s ==\033[0m\n' "$*"; }
ALERTAS=0
[ "$(id -u)" -eq 0 ] || inf "Rode com sudo para checagens completas."

sec "Sistema"
inf "$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-desconhecido}") · kernel $(uname -r)"
if command -v apt-get >/dev/null; then
  N=$(apt-get -s upgrade 2>/dev/null | grep -c '^Inst')
  SEC=$(apt-get -s upgrade 2>/dev/null | grep '^Inst' | grep -ci security)
  [ "$N" -eq 0 ] && ok "Sem atualizações pendentes" || al "$N pacotes para atualizar ($SEC de segurança) → sudo apt update && sudo apt full-upgrade"
  dpkg -l unattended-upgrades 2>/dev/null | grep -q '^ii' && ok "unattended-upgrades instalado" || al "Sem atualização automática → sudo apt install unattended-upgrades"
fi
[ -f /var/run/reboot-required ] && al "Reinício pendente para aplicar atualizações do kernel"

sec "SSH"
if command -v sshd >/dev/null; then
  CFG=$(sshd -T 2>/dev/null)
  v(){ echo "$CFG" | awk -v k="$1" '$1==k{print $2; exit}'; }
  [ "$(v permitrootlogin)" = "no" ] && ok "Root não entra por SSH" || al "PermitRootLogin = $(v permitrootlogin) → use 'no'"
  [ "$(v passwordauthentication)" = "no" ] && ok "Login por senha desligado" || al "PasswordAuthentication = yes → só chave SSH (veja 00-nexusup.conf)"
  [ "$(v kbdinteractiveauthentication)" = "no" ] && ok "Keyboard-interactive desligado" || al "KbdInteractiveAuthentication ligado"
  M=$(v maxauthtries); [ "${M:-6}" -le 3 ] && ok "MaxAuthTries = $M" || al "MaxAuthTries = ${M:-?} (recomendado 3)"
  [ "$(v x11forwarding)" = "no" ] && ok "X11Forwarding desligado" || al "X11Forwarding ligado"
  inf "Porta SSH: $(v port)"
else inf "sshd não encontrado"; fi

sec "Usuários"
U0=$(awk -F: '$3==0{print $1}' /etc/passwd | tr '\n' ' ')
[ "$U0" = "root " ] && ok "Só root tem UID 0" || al "Usuários com UID 0: $U0"
inf "Membros do sudo: $(getent group sudo | cut -d: -f4)"
if [ -r /etc/shadow ]; then
  E=$(awk -F: '($2==""){print $1}' /etc/shadow)
  [ -z "$E" ] && ok "Nenhuma conta sem senha" || al "Contas sem senha: $E"
fi
inf "Últimos logins:"; last -n 5 2>/dev/null | head -5 | sed 's/^/           /'

sec "Firewall e portas"
if command -v ufw >/dev/null; then
  ufw status 2>/dev/null | grep -q 'Status: active' && ok "UFW ativo" || al "UFW inativo → sudo ufw enable (depois de liberar o SSH)"
else al "UFW não instalado"; fi
inf "Portas ouvindo em todas as interfaces (públicas):"
PUB=$(ss -tulpnH 2>/dev/null | awk '{print $5" "$7}' | grep -Ev '^(127\.|\[::1\]|::1)' )
echo "$PUB" | sed 's/^/           /'
echo "$PUB" | grep -Eq ':(3306|5432|6379|27017|9200|11211|2375|2376|5984|8086)\b' \
  && al "Banco/cache/Docker API exposto publicamente! Prenda em 127.0.0.1" \
  || ok "Nenhuma porta de banco/cache/Docker API pública"

sec "Proteções"
systemctl is-active --quiet fail2ban && ok "Fail2ban ativo" || { systemctl is-active --quiet crowdsec && ok "CrowdSec ativo" || al "Sem Fail2ban/CrowdSec"; }
systemctl is-active --quiet apparmor && ok "AppArmor ativo" || inf "AppArmor inativo"
systemctl is-active --quiet auditd && ok "auditd ativo" || inf "auditd não instalado (recomendado)"
for k in net.ipv4.tcp_syncookies:1 net.ipv4.conf.all.accept_redirects:0 net.ipv4.conf.all.send_redirects:0 kernel.kptr_restrict:2 kernel.dmesg_restrict:1 fs.protected_symlinks:1; do
  n=${k%%:*}; w=${k##*:}; c=$(sysctl -n "$n" 2>/dev/null)
  [ "$c" = "$w" ] && ok "sysctl $n = $c" || al "sysctl $n = ${c:-?} (recomendado $w)"
done

sec "Docker"
if command -v docker >/dev/null; then
  docker ps --format '{{.Names}}|{{.Ports}}' 2>/dev/null | while IFS='|' read -r n p; do
    echo "$p" | grep -Eq '0\.0\.0\.0:|:::' && al "Container $n publica porta para o mundo: $p" || ok "Container $n: $p"
  done
  for c in $(docker ps -q 2>/dev/null); do
    n=$(docker inspect -f '{{.Name}}' "$c"); priv=$(docker inspect -f '{{.HostConfig.Privileged}}' "$c")
    usr=$(docker inspect -f '{{.Config.User}}' "$c")
    [ "$priv" = "true" ] && al "$n roda --privileged"
    [ -z "$usr" ] || [ "$usr" = "root" ] || [ "$usr" = "0" ] && inf "$n roda como root (prefira user: 1000)"
    docker inspect -f '{{range .Mounts}}{{.Source}} {{end}}' "$c" | grep -q docker.sock && al "$n tem docker.sock montado"
  done
else inf "Docker não instalado"; fi

sec "Arquivos sensíveis"
F=$(find / -xdev \( -name '.env' -o -name '*.pem' -o -name 'id_rsa' -o -name 'id_ed25519' \) -type f -perm /o+r 2>/dev/null | grep -v '/proc/' | head -20)
[ -z "$F" ] && ok "Nenhum .env/chave legível por outros usuários" || { al "Arquivos sensíveis legíveis por todos (chmod 600):"; echo "$F" | sed 's/^/           /'; }
W=$(find / -xdev -type f -perm -0002 ! -path '/proc/*' ! -path '/sys/*' ! -path '/tmp/*' ! -path '/var/tmp/*' 2>/dev/null | head -10)
[ -z "$W" ] && ok "Sem arquivos graváveis por todos" || { al "Arquivos graváveis por qualquer usuário:"; echo "$W" | sed 's/^/           /'; }

sec "Resultado"
[ "$ALERTAS" -eq 0 ] && ok "Nenhum alerta. Rode também: sudo lynis audit system" || al "$ALERTAS alerta(s). Corrija pelo guia NexusUp-Blindagem e rode de novo."
