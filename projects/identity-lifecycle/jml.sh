#!/usr/bin/env bash
# BAU home lab: joiner, mover, leaver on a local Samba AD domain controller (Docker).
# Stands in for Microsoft 365 / Entra user administration when no tenant is available.
# Usage: ./jml.sh up | joiner | mover | leaver | reset | report | down
set -euo pipefail

DOMAIN="LAB.LOCAL"
BASE="DC=lab,DC=local"
ADMINPASS="${ADMINPASS:-LabAdmin!2026}"
C="samba"
LOG="evidence/jml-log.csv"
st() { docker exec "$C" samba-tool "$@"; }
log() { mkdir -p evidence; [ -f "$LOG" ] || echo "time,ticket,action,user,detail" > "$LOG"; echo "$(date '+%F %T'),$1,$2,$3,$4" >> "$LOG"; echo "[$1] $2 $3: $4"; }
ldif() { docker exec -i "$C" ldbmodify -H /var/lib/samba/private/sam.ldb; }

case "${1:-}" in
up)
  cat > docker-compose.yml <<EOF
services:
  samba:
    image: nowsci/samba-domain
    container_name: $C
    hostname: dc1
    environment:
      - DOMAIN=$DOMAIN
      - DOMAINPASS=$ADMINPASS
    volumes:
      - ./data:/var/lib/samba
      - ./config:/etc/samba/external
    privileged: true
EOF
  docker compose up -d
  echo "Waiting for the domain to provision..."; sleep 45
  st ou create "OU=Staff,$BASE" || true
  st ou create "OU=Leavers,$BASE" || true
  for g in SG-Sales SG-Finance SG-Mailbox-Sales SG-Mailbox-Finance; do st group add "$g" || true; done
  st domain info 127.0.0.1
  ;;
joiner)
  for u in alex.tane:Alex:Tane sam.ruka:Sam:Ruka; do
    IFS=: read -r id gn sn <<<"$u"
    st user create "$id" 'Welcome!2026' --given-name="$gn" --surname="$sn" \
      --department=Sales --job-title="Sales Coordinator" \
      --mail-address="$id@lab.local" --userou=OU=Staff --must-change-at-next-login
    st group addmembers SG-Sales "$id"
    st group addmembers SG-Mailbox-Sales "$id"
    log "INC-1001" joiner "$id" "created in OU=Staff; SG-Sales; Sales mailbox access; change password at next sign-in"
  done
  ;;
mover)
  id=alex.tane
  ldif <<EOF
dn: CN=Alex Tane,OU=Staff,$BASE
changetype: modify
replace: department
department: Finance
-
replace: title
title: Finance Officer
EOF
  st group removemembers SG-Sales "$id"
  st group removemembers SG-Mailbox-Sales "$id"
  st group addmembers SG-Finance "$id"
  st group addmembers SG-Mailbox-Finance "$id"
  log "REQ-1002" mover "$id" "Sales to Finance; groups and mailbox access swapped"
  ;;
leaver)
  id=sam.ruka
  st user disable "$id"
  st user setpassword "$id" --newpassword="$(openssl rand -base64 18)"
  for g in $(st user getgroups "$id" | grep -v '^Domain Users$'); do st group removemembers "$g" "$id"; done
  st user move "$id" OU=Leavers
  log "REQ-1003" leaver "$id" "disabled; password scrambled; groups removed; moved to OU=Leavers"
  ;;
reset)
  id=alex.tane
  st user setpassword "$id" --newpassword='Temp!Reset2026' --must-change-at-next-login
  st user enable "$id"
  log "INC-1004" password-reset "$id" "temporary password set; change required at next sign-in"
  ;;
report)
  for id in alex.tane sam.ruka; do
    echo "== $id"; st user show "$id" --attributes=department,title,userAccountControl,distinguishedName
    echo "groups:"; st user getgroups "$id"
  done
  echo; cat "$LOG"
  ;;
down) docker compose down ;;
*) echo "Usage: $0 up | joiner | mover | leaver | reset | report | down"; exit 1 ;;
esac
