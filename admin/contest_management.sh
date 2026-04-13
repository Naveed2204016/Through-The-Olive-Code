#!/bin/bash

# ============================================
# CONTEST MANAGEMENT - Admin Functions
# ============================================

source ./utils.sh

# Create a new contest (including virtual contests)
create_contest() {
    clear
    echo "=========================================="
    echo "       🎯 CREATE NEW CONTEST 🎯           "
    echo "=========================================="
    echo
    
    read -p "📄 Enter contest name: " contest_name
    read -p "🔢 Enter division: " division
    
    # Check if contest already exists
    if grep -q "^$contest_name|" database/contest.txt 2>/dev/null; then
        echo "❌ Contest '$contest_name' already exists!"
        sleep 2
        return 1
    fi
    
    echo ""
    echo "📋 Contest Type:"
    echo "1️⃣  Live Contest (scheduled time)"
    echo "2️⃣  Virtual Contest (always available)"
    read -p "👉 Choose contest type (1 or 2): " contest_type
    
    if [ "$contest_type" = "1" ]; then
        is_virtual=0
        read -p "📅 Enter contest date (YYYY-MM-DD): " contest_date
        read -p "⏰ Enter start time (HH:MM): " contest_start_time
        read -p "⏰ Enter end time (HH:MM): " contest_end_time
    elif [ "$contest_type" = "2" ]; then
        is_virtual=1
        contest_date="VIRTUAL"
        contest_start_time="00:00"
        contest_end_time="23:59"
        echo "✅ Virtual contest mode selected - available anytime!"
    else
        echo "❌ Invalid choice!"
        sleep 1
        return 1
    fi
    
    # Create contest entry
    echo "$contest_name|$division|${contest_name}_applicants.txt|${contest_name}_ps.txt|${contest_name}_t_problems.txt|${contest_name}_f_problems.txt|$contest_date|$contest_start_time|$contest_end_time|$is_virtual" >> database/contest.txt
    
    # Create necessary files
    touch "./database/${contest_name}_applicants.txt"
    touch "./database/${contest_name}_ps.txt"
    touch "./database/${contest_name}_t_problems.txt"
    touch "./database/${contest_name}_f_problems.txt"
    touch "./database/registration/${contest_name}.txt"
    touch "./database/contest_submissions/${contest_name}.txt"
    touch "./database/final_leaderboard/${contest_name}.txt"
    
    # Add to selection queues
    echo "$contest_name" >> ./database/ps_selection_in_progress.txt
    echo "$contest_name" >> ./database/problem_selection_in_progress.txt
    
    if [ "$is_virtual" = "1" ]; then
        echo "✅ Virtual Contest '$contest_name' created successfully!"
    else
        echo "✅ Live Contest '$contest_name' created successfully!"
    fi
    sleep 2
}

# Update a contest's scheduled time
update_contest_time() {
    clear
    echo "=========================================="
    echo "    ⏰ UPDATE CONTEST TIME ⏰             "
    echo "=========================================="
    echo
    
    if [ ! -f ./database/contest.txt ]; then
        echo "❌ No contests found!"
        sleep 2
        return 1
    fi
    
    echo "📋 Available Contests:"
    cat -n ./database/contest.txt | head -20
    echo
    
    read -p "👉 Enter the number of the contest to update: " contest_idx
    
    contest_name=$(sed -n "${contest_idx}p" ./database/contest.txt | cut -d'|' -f1)
    
    if [ -z "$contest_name" ]; then
        echo "❌ Invalid selection."
        sleep 2
        return 1
    fi
    
    echo ""
    echo "Current contest: $contest_name"
    echo ""
    
    # Check if it's a virtual contest
    is_virt=$(sed -n "${contest_idx}p" ./database/contest.txt | cut -d'|' -f10)
    
    if [ "$is_virt" = "1" ]; then
        echo "⚠️  This is a virtual contest. Time updates don't affect availability."
    fi
    
    read -p "📅 Enter new contest date (YYYY-MM-DD): " new_date
    read -p "⏰ Enter new start time (HH:MM): " new_start_time
    read -p "⏰ Enter new end time (HH:MM): " new_end_time
    
    echo ""
    echo "Updating contest time..."
    
    # Use sed to update the specific contest entry
    # This is complex, so we'll use awk to rebuild the file
    awk -v idx="$contest_idx" -v nd="$new_date" -v nst="$new_start_time" -v net="$new_end_time" \
    'BEGIN {FS="|"; OFS="|"} NR==idx {
        $7=nd; $8=nst; $9=net;
    } {print}' \
    ./database/contest.txt > ./database/contest.txt.tmp && \
    mv ./database/contest.txt.tmp ./database/contest.txt
    
    echo "✅ Contest time updated successfully!"
    echo "   New Date: $new_date"
    echo "   New Start Time: $new_start_time"
    echo "   New End Time: $new_end_time"
    sleep 2
}

# View all available contests
view_all_contests() {
    clear
    echo "=========================================="
    echo "    📋 ALL CONTESTS 📋                    "
    echo "=========================================="
    echo
    
    if [ ! -f ./database/contest.txt ]; then
        echo "❌ No contests found!"
        sleep 2
        return
    fi
    
    echo "Live Contests:"
    echo "═════════════════════════════════════════"
    awk -F'|' '$10==0 {printf "%s | %s | %s (%s-%s)\n", $1, $7, $8, $9}' ./database/contest.txt
    
    echo ""
    echo "Virtual Contests:"
    echo "═════════════════════════════════════════"
    awk -F'|' '$10==1 {printf "%s | (Always Available)\n", $1}' ./database/contest.txt
    
    echo ""
    read -p "Press Enter to continue..."
}

export -f create_contest
export -f update_contest_time
export -f view_all_contests
