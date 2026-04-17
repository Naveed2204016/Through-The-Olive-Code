#!/bin/bash

clear
echo "========================================"
echo "          👑 ADMIN DASHBOARD 👑         "
echo "========================================"
echo
echo "1️⃣  Create a New Contest"
echo "2️⃣  Select Problem Setters"
echo "3️⃣  Select Problem Set"
echo "4️⃣  Manage Contestants"
echo "5️⃣  Manage Problem Setters"
echo "6️⃣  Cancel a Contest"
echo "7️⃣  Exit"
echo

read -p "👉 Choose an option: " choice


if [ "$choice" = "1" ]; then
    read -p "📄 Enter contest name: " contest_name
    read -p "🔢 Enter division :" division
    read -p "📅 Enter contest date (YYYY-MM-DD): " contest_date
    echo "$contest_name|$division|${contest_name}_applicants.txt|${contest_name}_ps.txt|${contest_name}_t_problems.txt|${contest_name}_f_problems.txt|$contest_date||" >> database/contest.txt
    touch "./database/${contest_name}_applicants.txt"
    touch "./database/${contest_name}_ps.txt"
    touch "./database/${contest_name}_t_problems.txt"
    touch "./database/${contest_name}_f_problems.txt"
    echo "$contest_name" >> ./database/ps_selection_in_progress.txt
    echo "$contest_name" >> ./database/problem_selection_in_progress.txt
    echo "Calling for Problem Setters..."
    touch "./database/registration/${contest_name}.txt"
    touch "./database/contest_submissions/${contest_name}.txt"
    touch "./database/final_leaderboard/${contest_name}.txt"
    sleep 1
    ./admin/admin_dashboard_main.sh
elif [ "$choice" = "2" ]; then
    selection_file="./database/ps_selection_in_progress.txt"
    if [ ! -s "$selection_file" ]; then
    echo "No contests are currently in selection."
    exit 0
    fi
    echo "📋 Contests in selection:"
    cat -n "$selection_file"
    read -p "👉 Enter the number of the contest to select problem setters: " contest_idx
    contest_name=$(sed -n "${contest_idx}p" "$selection_file" | tr -d '{}' | xargs)
    
    if [ -z "$contest_name" ]; then
    echo "❌ Invalid selection."
    ./admin/admin_dashboard_main.sh
    fi
    
    echo "You selected: $contest_name"

    APPLICANTS_FILE="./database/${contest_name}_applicants.txt"
    FINAL_SETTERS_FILE="./database/${contest_name}_ps.txt"

    if [ ! -s "$APPLICANTS_FILE" ]; then
    echo "❌ No applicants found for this contest."
    ./admin/admin_dashboard_main.sh
    fi
    
    # Show applicants
    echo "📋 Applicants for $contest_name:"
    cat -n "$APPLICANTS_FILE"
    echo
    # Admin selects problem setters
    echo "Select 2-3 problem setters by entering their numbers separated by space (e.g., 1 3 5):"
    read -a setter_indices
    
    # Clear final setters file
    > "$FINAL_SETTERS_FILE"

    # Save selected problem setters
    for idx in "${setter_indices[@]}"; 
    do
    setter=$(sed -n "${idx}p" "$APPLICANTS_FILE")
    if [ -n "$setter" ]; then
        echo "$setter" >> "$FINAL_SETTERS_FILE"
    fi
    done
    
    echo "✅ Problem setters finalized for $contest_name:"
    cat "$FINAL_SETTERS_FILE"

    # will notify selected and rejected problem setters and give them
    # access to problem setting accordingly (not implemented yet)

    sed -i "${contest_idx}d" ./database/ps_selection_in_progress.txt
    echo "✅ $contest_name removed from problem_setter_selection_in_progress.txt"
    ./admin/admin_dashboard_main.sh

elif [ "$choice" = "3" ]; then
    echo "📋 Contests in problem selection:"

    cat -n ./database/problem_selection_in_progress.txt
    echo
    read -p "👉 Enter the number of the contest to select problem set: " contest_idx
    contest_name=$(sed -n "${contest_idx}p" "./database/problem_selection_in_progress.txt" | tr -d '{}' | xargs)
    
    if [ -z "$contest_name" ]; then
        echo "❌ Invalid selection."
        ./admin/admin_dashboard_main.sh
    fi

    echo "Submitted problems for $contest_name:"
    cat -n "./database/${contest_name}_t_problems.txt"
    echo

    while true; 
    do
    echo "1️⃣  View a Problem"
    echo "2️⃣  Finalize Problem Set"
    read -p "👉 Choose an option: " problem_selection_choice
    
        if [ "$problem_selection_choice" = "1" ]; then
           read -p "👉 Enter the number of the problem to view: " problem_idx
           content=$(sed -n "${problem_idx}p" "./database/${contest_name}_t_problems.txt" | tr -d '{}' | xargs)
           problem_name="${content%%|*}"
           echo "Problem Statement for $problem_name:"
           cat "./database/problem_statement/${problem_name}_statement.txt"
           echo
           echo "Would you like to view the test cases? (y/n)"
           read view_cases
           if [ "$view_cases" = "y" ]; then
           num_cases=$(echo "$content" | cut -d '|' -f 4)
           for((i=1;i<=num_cases;i++)); 
           do
           echo "Test Case $i :"
           cat "./database/test_case/${problem_name}_testcase${i}.txt"
           echo
           done
           sleep 6
           fi
        elif [ "$problem_selection_choice" = "2" ]; then
           echo "Select problems by entering their numbers separated by space (e.g., 1 3 5):"
           read -a problem_indices
           for idx in "${problem_indices[@]}"; 
           do
           problem=$(sed -n "${idx}p" "./database/${contest_name}_t_problems.txt" )
           echo "$problem" >> "./database/${contest_name}_f_problems.txt"
           done
           echo "Problem set finalized for $contest_name"
           read -p "⏰ Enter start time (HH:MM): " contest_start_time
           read -p "⏰ Enter end time (HH:MM): " contest_end_time
           updated_contest_file=$(awk -F'|' -v OFS='|' -v name="$contest_name" -v start="$contest_start_time" -v end="$contest_end_time" '
           {
               if ($1 == name) {
                   $8 = start
                   $9 = end
               }
               print
           }' ./database/contest.txt)
           printf '%s\n' "$updated_contest_file" > ./database/contest.txt
           echo
           cat "./database/${contest_name}_f_problems.txt"
           sleep 3
           sed -i "${contest_idx}d" "./database/problem_selection_in_progress.txt"
           break
        else
           echo "❌ Invalid option!"
           break
        fi
    done
    sleep 1
    ./admin/admin_dashboard_main.sh
elif [ "$choice" = "4" ]; then
    echo "Registered Contestants of this platform:"
    cat -n database/contestant.txt
    echo
    echo "Select a contestant to manage by entering their number:"
    read contestant_idx
    echo "1️⃣  Remove Contestant"
    echo "2️⃣  Update Rating"
    read -p "👉 Choose an option: " manage_choice
    if [ "$manage_choice" = "1" ]; then
        sed -i "${contestant_idx}d" ./database/contestant.txt
        echo "✅ Contestant removed."
        sleep 1
    elif [ "$manage_choice" = "2" ]; then
        contestant=$(sed -n "${contestant_idx}p" database/contestant.txt)
        read -p "👉 Enter new rating for $contestant: " new_rating
        updated_contestant=$(echo "$contestant" | awk -F'|' -v OFS='|' '{ $3="'$new_rating'"; print }')
        sed -i "${contestant_idx}d" ./database/contestant.txt
        echo "$updated_contestant" >> database/contestant.txt
        echo "✅ Contestant rating updated."
    else
        echo "❌ Invalid option."
    fi
    ./admin/admin_dashboard_main.sh
elif [ "$choice" = "5" ]; then
    echo "Registered Problem Setters of this platform:"
    cat -n database/problem_setter.txt
    echo
    echo "Select a problem setter to manage by entering their number:"
    read setter_idx
    echo "1️⃣  Remove Problem Setter"
    echo "2️⃣  Update Rating"
    read -p "👉 Choose an option: " manage_choice
    if [ "$manage_choice" = "1" ]; then
        sed -i "${setter_idx}d" ./database/problem_setter.txt
        echo "✅ Problem Setter removed."
    elif [ "$manage_choice" = "2" ]; then
        setter=$(sed -n "${setter_idx}p" database/problem_setter.txt)
        read -p "👉 Enter new rating for $setter: " new_rating
        updated_setter=$(echo "$setter" | awk -F'|' -v OFS='|' '{ $3="'$new_rating'"; print }')
        sed -i "${setter_idx}d" ./database/problem_setter.txt
        echo "$updated_setter" >> database/problem_setter.txt
        echo "✅ Problem Setter rating updated."
    else
        echo "❌ Invalid option."
    fi
    ./admin/admin_dashboard_main.sh
elif [ "$choice" = "6" ]; then
    echo "📋 Ongoing Contests:"
    cat -n database/contest.txt
    read -p "👉 Enter the number of the contest to cancel: " contest_idx
    contest_name=$(sed -n "${contest_idx}p" database/contest.txt | cut -d'|' -f1)
    
    if [ -z "$contest_name" ]; then
        echo "❌ Invalid selection."
        exit 1
    fi
    
    echo "You selected to cancel: $contest_name"
    
    # Remove contest from contest.txt
    sed -i "${contest_idx}d" ./database/contest.txt

    # Remove related files
    rm -f "./database/${contest_name}_applicants.txt"
    rm -f "./database/${contest_name}_ps.txt"
    rm -f "./database/${contest_name}_t_problems.txt"
    rm -f "./database/${contest_name}_f_problems.txt"

    # Also remove from ps_selection_in_progress if it's there, need to fix it later
    grep -vxF "$contest_name" database/ps_selection_in_progress.txt > database/ps_selection_in_progress.tmp && mv database/ps_selection_in_progress.tmp database/ps_selection_in_progress.txt
    
    echo "✅ $contest_name has been cancelled and all related data has been removed."
    ./admin/admin_dashboard_main.sh
elif [ "$choice" = "7" ]; then
    echo "👋 Exiting Admin Dashboard..."
    sleep 6
    ./admin/admin_dashboard.sh
else
    echo "❌ Invalid option. Please try again."
    ./admin/admin_dashboard_main.sh
fi