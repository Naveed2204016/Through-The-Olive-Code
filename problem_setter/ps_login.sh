#!/bin/bash

clear
echo "========================================"
echo "       🔐 Problem Setter LOGIN          "
echo "========================================"
echo

read -p "👤 Enter username: " username
read -s -p "🔑 Enter password: " password
echo

password_hash=$(echo "$password" | sha256sum | awk '{print $1}')

if grep -q "^$username|$password_hash$" database/problem_setter.txt; then
    echo
    echo "✅ Login successful!"
    sleep 1
    ./problem_setter/ps_dashboard_main.sh "$username"
else
    echo
    echo "❌ Invalid username or password!"
    sleep 2
    ./problem_setter/ps_dashboard.sh
fi
