#!/usr/bin/bash

echo "========== SCRIPT BY ==========="
echo "=========== CENOZEX ============"

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "ERROR: .env file not found!"
    exit 1
fi

# Validate essential variables
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    echo "ERROR: DISCORD_WEBHOOK_URL is not set"
    exit 1
fi

# Set defaults if not in .env
POLL_INTERVAL=${POLL_INTERVAL:-30}
COOLDOWN_PERIOD=300 # 5 minutes (prevents spam)
LAST_ALERT_TIME=0

echo "✅ Configuration loaded."
echo "Monitoring: $SERVER_HEALTH_URL & $DB_HEALTH_URL"
echo "------------------------------------------------"

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    CURRENT_TIME=$(date +%s)
    SEND_ALERT=false
    
    # --- 1. CHECK SERVER HEALTH ---
    SERVER_RESPONSE=$(curl -s --max-time 5 "$SERVER_HEALTH_URL")
    if [ $? -ne 0 ] || [ -z "$SERVER_RESPONSE" ]; then
        SERVER_STATUS="DOWN (Connection Failed)"
        SEND_ALERT=true
    else
        # Extract 'online' field and normalize to lowercase
        SERVER_RAW=$(echo "$SERVER_RESPONSE" | jq -r '.online // "UNKNOWN"' | tr '[:upper:]' '[:lower:]')
        if [[ "$SERVER_RAW" == "up" ]]; then
            SERVER_STATUS="UP"
        else
            SERVER_STATUS="DOWN ($SERVER_RAW)"
            SEND_ALERT=true
        fi
    fi

    # --- 2. CHECK DATABASE HEALTH ---
    DB_RESPONSE=$(curl -s --max-time 5 "$DB_HEALTH_URL")
    if [ $? -ne 0 ] || [ -z "$DB_RESPONSE" ]; then
        DB_STATUS="DOWN (Connection Failed)"
        SEND_ALERT=true
    else
        # Extract 'database' field and normalize to lowercase for reliable comparison
        DB_RAW=$(echo "$DB_RESPONSE" | jq -r '.database // "UNKNOWN"' | tr '[:upper:]' '[:lower:]')
        
        # Checking for "connected" as per your backend response
        if [[ "$DB_RAW" == "connected" ]]; then
            DB_STATUS="UP"
        else
            DB_STATUS="DOWN ($DB_RAW)"
            SEND_ALERT=true
        fi
    fi

    # --- 3. CONSOLE LOGGING ---
    echo "[$TIMESTAMP] Server: $SERVER_STATUS | DB: $DB_STATUS"

    # --- 4. ALERT LOGIC (With Cooldown) ---
    if [ "$SEND_ALERT" = true ]; then
        # Check if we are still in cooldown to avoid spamming Discord
        if (( CURRENT_TIME - LAST_ALERT_TIME > COOLDOWN_PERIOD )); then
            
            ALERT_MSG="🚨 ALERT: Booking System Error - [$TIMESTAMP]\n\n**Server Status:** $SERVER_STATUS\n**DB Status:** $DB_STATUS\n\nCheck logs immediately!"

            # Escape for JSON
            PAYLOAD=$(printf '{"content": "%s"}' "$ALERT_MSG")

            curl -s -X POST -H "Content-Type: application/json" \
                 -d "$PAYLOAD" \
                 "$DISCORD_WEBHOOK_URL" > /dev/null
            
            echo "📢 Alert sent to Discord."
            LAST_ALERT_TIME=$CURRENT_TIME
        else
            echo "⏳ Issue persists, but alert suppressed (Cooldown Active)."
        fi
    else
        # Reset cooldown if system comes back healthy
        LAST_ALERT_TIME=0
    fi

    sleep "$POLL_INTERVAL"
done