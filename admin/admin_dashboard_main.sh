#!/bin/bash

clear
echo "========================================"
echo "          👑 ADMIN DASHBOARD 👑         "
echo "========================================"
echo
echo "1️⃣  Create Contest"
echo "2️⃣  Review Problems"
echo "3️⃣  Manage Users"
echo "4️⃣  Logout"
echo

read -p "👉 Choose an option: " choice

case $choice in
  1)
    echo "🛠️ Create Contest (coming soon)"
    ;;
  2)
    echo "📋 Review Problems (coming soon)"
    ;;
  3)
    echo "👥 Manage Users (coming soon)"
    ;;
  4)
    echo "👋 Logging out..."
    sleep 1
    ./main.sh
    ;;
  *)
    echo "❌ Invalid option"
    sleep 1
    ./admin_dashboard_main.sh
    ;;
esac
