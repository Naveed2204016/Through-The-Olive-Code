#!/bin/bash

clear
echo "========================================"
echo "       📝 Problem Setter SIGN UP       "
echo "========================================"
echo

read -p "👤 Enter username: " username

# Check if username already exists
if grep -q "^$username|" database/problem_setter.txt; then
    echo
    echo "❌ Username already exists!"
    sleep 2
    ./problem_setter/ps_dashboard.sh
    exit
fi

read -s -p "🔑 Enter password: " password
echo
read -s -p "🔁 Confirm password: " confirm_password
echo

if [ "$password" != "$confirm_password" ]; then
    echo
    echo "❌ Passwords do not match!"
    sleep 2
    ./problem_setter/ps_dashboard.sh
    exit
fi

# Hash password
password_hash=$(echo "$password" | sha256sum | awk '{print $1}')

# Save to database
echo "$username|$password_hash" >> database/problem_setter.txt

echo
echo "✅ Signup successful!"
sleep 2
./problem_setter/ps_dashboard.sh
