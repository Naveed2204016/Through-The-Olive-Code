#!/bin/bash

# ============================================
# ANONYMOUS CONTEST LOGIN
# ============================================

source ./utils.sh

clear
echo "========================================"
echo "  🕵️ ANONYMOUS CONTEST LOGIN 🕵️        "
echo "========================================"
echo
echo "📝 You are about to enter as an anonymous user."
echo "   Your identity will be hidden from leaderboards"
echo "   Your stats will be recorded as @anonymous_XXXXXX"
echo ""

# Generate anonymous username
anonymous_username=$(generate_anonymous_username)

echo "✅ Anonymous Username: $anonymous_username"
echo ""

# Show available contests
echo "🏟️  Available Contests:"
echo "----------------------"

contest_file="./database/contest.txt"
current_date=$(date +%Y-%m-%d)
current_time=$(date +%H:%M)

available_contests=()
line_number=1

if [ ! -f "$contest_file" ]; then
    echo "❌ No contests available."
    sleep 2
    exit 1
fi

# Show both live and virtual contests
while IFS="|" read -r contest_name division applicants_file ps_file t_problems f_problems contest_date start_time end_time is_virtual
do
    # For live contests
    if [ "$is_virtual" = "0" ]; then
        if [ "$contest_date" = "$current_date" ]; then
            if [[ ("$current_time" > "$start_time" || "$current_time" = "$start_time") && \
                  ("$current_time" < "$end_time" || "$current_time" = "$end_time") ]]; then
                echo "$line_number) 🟢 $contest_name (LIVE)"
                available_contests+=("$contest_name")
                ((line_number++))
            fi
        fi
    # For virtual contests
    else
        echo "$line_number) 🔵 $contest_name (VIRTUAL)"
        available_contests+=("$contest_name")
        ((line_number++))
    fi
done < "$contest_file"

# No available contests
if [ ${#available_contests[@]} -eq 0 ]; then
    echo ""
    echo "❌ No contests available at this moment."
    read -p "Press Enter to go back..."
    exit 1
fi

echo ""
read -p "👉 Enter contest number or 'back' to cancel: " selection

if [ "$selection" = "back" ]; then
    exit 0
fi

# Validate numeric input
if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
    echo "❌ Invalid input."
    sleep 1
    exit 1
fi

# Validate range
if [ "$selection" -lt 1 ] || [ "$selection" -gt ${#available_contests[@]} ]; then
    echo "❌ Invalid selection."
    sleep 1
    exit 1
fi

selected_contest="${available_contests[$((selection-1))]}"

# Register anonymous user for contest
registration_file="./database/registration/${selected_contest}.txt"

if [ ! -f "$registration_file" ]; then
    touch "$registration_file"
fi

# Add anonymous user to registration
echo "$anonymous_username" >> "$registration_file"

echo ""
echo "✅ Successfully registered as $anonymous_username"
echo "   Entering contest: $selected_contest"
sleep 1

# Enter the contest arena with anonymous user
./contestant/contest_arena.sh "$anonymous_username" "$selected_contest"
