#!/bin/bash

clear
echo "========================================"
echo "           👑 ADMIN PANEL 👑            "
echo "========================================"
echo
echo "1️⃣  Login"
echo "2️⃣  Sign Up"
echo "3️⃣  Back to Landing Page"
echo
read -p "👉 Enter choice: " admin_choice

case $admin_choice in
  1)
    sleep 1
    ./admin/admin_login.sh
    ;;
  2)
    sleep 1
    ./admin/admin_signup.sh
    ;;
  3)
    ./main.sh
    ;;
  *)
    echo "❌ Invalid option"
    sleep 1
    ./admin/admin_dashboard.sh
    ;;
esac
