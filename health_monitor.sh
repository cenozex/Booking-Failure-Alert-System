#! /usr/bin/bash

echo "==========SCRIPT BY==========="
echo "===========CENOZEX============"


#========================================
#---------# CONFIG SYSTEM----------------
#========================================


source .env

if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    echo "ERROR: DISCORD_WEBHOOK_URL is not set"
    exit 1
fi

# Use variables from .env
HEALTH_URL="$HEALTH_URL"
HOTEL_API_URL="$HOTEL_API_URL"
HOTEL_API_THRESHOLD="$HOTEL_API_THRESHOLD"
POLL_INTERVAL="$POLL_INTERVAL"

echo "✅ Configuration loaded. Starting Health Monitor..."



#========================================
#---------# POLLER SYSTEM---------------
#========================================










#========================================
#---------# CHECKER SYSTEM---------------
#========================================













#========================================
#---------# NOTIFIER SYSTEM--------------
#========================================