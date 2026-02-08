#!/bin/bash

clear
echo "========================================"
echo "            🔐 ADMIN LOGIN              "
echo "========================================"
echo

read -p "👤 Enter username: " username
read -s -p "🔑 Enter password: " password
echo

password_hash=$(echo "$password" | sha256sum | awk '{print $1}')

if grep -q "^$username|$password_hash$" database/admin.txt; then
    echo
    echo "✅ Login successful!"
    sleep 1
    ./admin/admin_dashboard_main.sh
else
    echo
    echo "❌ Invalid username or password!"
    sleep 2
    ./admin/admin_dashboard.sh
fi
