#!/bin/bash

clear
echo "========================================"
echo "       🧠 Problem Setter PANEL 🧠      "
echo "========================================"
echo
echo "1️⃣  Login"
echo "2️⃣  Sign Up"
echo "3️⃣  Back to Landing Page"
echo
read -p "👉 Enter choice: " ps_choice

case $ps_choice in
  1)
    sleep 1
    ./problem_setter/ps_login.sh
    ;;
  2)
    sleep 1
    ./problem_setter/ps_signup.sh
    ;;
  3)
    ./main.sh
    ;;
  *)
    echo "❌ Invalid option"
    sleep 1
    ./problem_setter/ps_dashboard.sh
    ;;
esac