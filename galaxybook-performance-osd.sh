#   Add this script to your KDE Autostart settings.
#

# --- CONFIGURATION ---
FILE="/sys/firmware/acpi/platform_profile"

# --- DEPENDENCY CHECK ---
# Arch Linux and Plasma 6 use 'qdbus6', others use 'qdbus'
if command -v qdbus6 &> /dev/null; then
    QDBUS="qdbus6"
elif command -v qdbus &> /dev/null; then
    QDBUS="qdbus"
else
    echo "Error: qdbus/qdbus6 not found. Please install qt-tools."
    exit 1
fi

# --- ENVIRONMENT SETUP ---
# Crucial for running as a background service/cron/headless
export DISPLAY=:0
# Dynamically fetch the current user's DBus session address
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# --- INITIALIZATION ---
# Force an initial read to prevent a popup on login (set LAST_MODE="FORCE_INIT" to enable login popup)
if [ -f "$FILE" ]; then
    LAST_MODE="unknown"
else
    echo "Error: Samsung platform profile not found at $FILE"
    exit 1
fi

# --- MAIN MONITOR LOOP ---
while true; do      
    # 1. READ MODE (Optimized)
    # Use built-in 'read' to avoid spawning new processes (cat/tr) every 0.1s
    if read -r CURRENT_MODE < "$FILE"; then
        : # Successfully read
    else
        CURRENT_MODE=""
    fi

    # 2. GLITCH PROTECTION
    # If the sysfs file returns an empty string (common during switching), skip this cycle
    if [ -z "$CURRENT_MODE" ]; then
        sleep 0.1
        continue
                                                                         62,16         Bot
