#!/bin/bash

clear
echo "========================================"
echo "        ⚔️ Contestant PANEL ⚔️         "
echo "========================================"
echo
echo "1️⃣  Login"
echo "2️⃣  Sign Up"
echo "3️⃣  Anonymous Contest (No Login Required)"
echo "4️⃣  Back to Landing Page"
echo
read -p "👉 Enter choice: " contestant_choice


case $contestant_choice in
  1)
    sleep 1
    ./contestant/contestant_login.sh
    ;;
  2)
    sleep 1
    ./contestant/contestant_signup.sh
    ;;
  3)
    sleep 1
    ./contestant/anonymous_login.sh
    ;;
  4)
    ./main.sh
    ;;
  *)
    echo "❌ Invalid option"
    sleep 1
    ./contestant/contestant_dashboard.sh
    ;;
esac

#added dashboard
