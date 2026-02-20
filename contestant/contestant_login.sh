#!/bin/bash

clear
echo "========================================"
echo "         ⚔️ Contestant LOGIN            "
echo "========================================"
echo

read -p "👤 Enter username: " username
read -s -p "🔑 Enter password: " password
echo

password_hash=$(echo "$password" | sha256sum | awk '{print $1}')

if grep -q "^$username|${password_hash}|" database/contestant.txt; then
    echo
    echo "✅ Login successful!"
    sleep 1
    ./contestant/contestant_dashboard_main.sh "$username"
else
    echo
    echo "❌ Invalid username or password!"
    sleep 1
    ./contestant/contestant_dashboard.sh
fi
