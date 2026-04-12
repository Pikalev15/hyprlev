#!/usr/bin/env bash

LOCATION="Singapore"  # e.g. "London" or "New York" or leave empty for auto-detect

# Fetch weather from wttr.in - no API key needed
text=$(curl -sf "https://wttr.in/${LOCATION}?format=1" 2>/dev/null)

if [[ $? -ne 0 || -z "$text" ]]; then
    echo '{"text":"󰖑 N/A", "tooltip":"Weather unavailable"}'
    exit
fi

# Clean up extra whitespace
text=$(echo "$text" | sed -E 's/\s+/ /g' | xargs)

# Richer tooltip with more detail
tooltip=$(curl -sf "https://wttr.in/${LOCATION}?format=%l:+%C+%t+%w+%h+humidity" 2>/dev/null \
    | sed -E 's/\s+/ /g' | xargs)
tooltip=${tooltip:-"No details available"}

echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
