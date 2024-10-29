#!/bin/bash

API_KEY=""

REPORTED_IPS_FILE="/var/log/reported_ips.log"
NEWLY_REPORTED_IPS_FILE="/var/log/newly_reported_ips.txt"

[ ! -f "$REPORTED_IPS_FILE" ] && touch "$REPORTED_IPS_FILE"
[ ! -f "$NEWLY_REPORTED_IPS_FILE" ] && touch "$NEWLY_REPORTED_IPS_FILE"

declare -A JAIL_CATEGORIES
JAIL_CATEGORIES=(
  ["plesk-apache"]="21"
  ["plesk-apache-badbot"]="21"
  ["plesk-dovecot"]="10"
  ["plesk-modsecurity"]="20"
  ["plesk-panel"]="18"
  ["plesk-postfix"]="10"
  ["plesk-proftpd"]="18"
  ["plesk-roundcube"]="18"
  ["plesk-wordpress"]="20"
  ["recidive"]="18"
  ["ssh"]="18"
)

NEWLY_REPORTED=()

for JAIL in "${!JAIL_CATEGORIES[@]}"; do
  BANNED_IPS=$(sudo fail2ban-client status "$JAIL" | sed -n 's/.*Banned IP list:[[:space:]]*//p' | tr ',' ' ')

  if [ -z "$BANNED_IPS" ]; then
    continue
  fi

  for IP in $BANNED_IPS; do
    IP=$(echo "$IP" | xargs)

    if grep -q "^$IP$" "$REPORTED_IPS_FILE"; then
      continue
    fi

    RESPONSE=$(curl -sS -X POST https://api.abuseipdb.com/api/v2/report \
      -H "Key: $API_KEY" \
      -H "Accept: application/json" \
      -d "ip=$IP&categories=${JAIL_CATEGORIES[$JAIL]}&comment=Failed login attempt detected by Fail2Ban in $JAIL jail")

    if echo "$RESPONSE" | grep -qi "error"; then
      echo "Error reporting IP $IP: $RESPONSE"
    else
      echo "Successfully reported IP: $IP"
      echo "$IP" >> "$REPORTED_IPS_FILE"
      NEWLY_REPORTED+=("$IP")
      echo "$IP" >> "$NEWLY_REPORTED_IPS_FILE"
    fi
  done
done

if [ ${#NEWLY_REPORTED[@]} -gt 0 ]; then
  echo "Newly reported IPs:"
  for NEW_IP in "${NEWLY_REPORTED[@]}"; do
    echo "$NEW_IP"
  done
else
  echo "No new IPs were reported."
fi

