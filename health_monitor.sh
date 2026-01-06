#! /usr/bin/bash

echo "==========SCRIPT BY==========="
echo "===========CENOZEX============"

#========================================
#---------# CONFIG SYSTEM----------------
#========================================

source .env

# Validate Discord Webhook
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    echo "ERROR: DISCORD_WEBHOOK_URL is not set"
    exit 1
fi

# Use variables from .env
SERVER_HEALTH_URL="$SERVER_HEALTH_URL"
DB_HEALTH_URL="$DB_HEALTH_URL"
POLL_INTERVAL="$POLL_INTERVAL"

echo "✅ Configuration loaded. Starting Health Monitor..."
echo "Polling every $POLL_INTERVAL seconds..."

#========================================
#---------# POLLER & CHECKER LOOP--------
#========================================

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    SEND_ALERT=false

    # -------------------------
    # Poll server health
    # -------------------------
    SERVER_RESPONSE=$(curl -s "$SERVER_HEALTH_URL")
    if [ -z "$SERVER_RESPONSE" ]; then
        SERVER_STATUS="DOWN"
        SEND_ALERT=true
    else
        SERVER_STATUS=$(echo "$SERVER_RESPONSE" | jq -r '.status')
        if [[ "$SERVER_STATUS" != "up" ]]; then
            SEND_ALERT=true
        fi
    fi

    # -------------------------
    # Poll database health
    # -------------------------
    DB_RESPONSE=$(curl -s "$DB_HEALTH_URL")
    if [ -z "$DB_RESPONSE" ]; then
        DB_STATUS="DOWN"
        SEND_ALERT=true
    else
        DB_STATUS=$(echo "$DB_RESPONSE" | jq -r '.status')
        if [[ "$DB_STATUS" != "up" ]]; then
            SEND_ALERT=true
        fi
    fi

    #========================================
    #---------# NOTIFIER SYSTEM--------------
    #========================================
    if $SEND_ALERT; then
        ALERT="🚨 ALERT: Health Issue Detected
Server: $SERVER_STATUS
Database: $DB_STATUS
Timestamp: $TIMESTAMP"

        curl -s -H "Content-Type: application/json" \
             -d "{\"content\":\"$ALERT\"}" \
             "$DISCORD_WEBHOOK_URL"
    fi

    # Wait before next poll
    sleep "$POLL_INTERVAL"
done
