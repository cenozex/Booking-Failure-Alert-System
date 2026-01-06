#! /usr/bin/bash

echo "==========SCRIPT BY==========="
echo "===========CENOZEX============"


#========================================
#---------# CONFIG SYSTEM----------------
#========================================

source .env # webhook url and other are loaded.


# Validate webhook
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    echo "ERROR: DISCORD_WEBHOOK_URL is not set in .env"
    exit 1
fi

# Log file path
LOG_DIR="$HOME/booking_app"
LOG_FILE="$LOG_DIR/booking.log"

# Create directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
    echo "INFO: Log directory not found, creating $LOG_DIR..."
    mkdir -p "$LOG_DIR"
fi

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "INFO: Log file not found, creating $LOG_FILE..."
    touch "$LOG_FILE"
fi

# Patterns to watch
PATTERN_1="Payment Failed"
PATTERN_2="DB Connection Lost"

echo "✅ Configuration loaded. Starting Booking Alert Watcher..."


# ==========================
# -----WATCHER SECTION------
# ==========================




# Follow log file in real-time
tail -F "$LOG_FILE" | while read -r line; do



# ==========================
# -----MATCHER SECTION------
# ==========================
if [[ "$line" == *"$PATTERN_1"* ]] || [[ "$line" == *"$PATTERN_2"* ]]; then
        
# =========================
# ----NOTIFIER SECTION-----
# =========================
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
ALERT_MESSAGE="🚨 ALERT: Booking System Error - $TIMESTAMP - Check Logs Immediately"

#Send alert to Discord
curl -s -H "Content-Type: application/json" \
-d "{\"content\":\"$ALERT_MESSAGE\"}" \
"$DISCORD_WEBHOOK_URL"

#Anti-spam cooldown
sleep 15
fi

done
