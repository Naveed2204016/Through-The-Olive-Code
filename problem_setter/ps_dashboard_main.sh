#!/bin/bash
clear
username="$1"

echo "========================================"
echo "     🧠 Problem Setter DASHBOARD  🧠   "
echo "========================================"
echo
echo "1️⃣  Create a New Problem"
echo "2️⃣  View your Problems" 
echo "3️⃣  Apply to be a Contest Setter"
echo "4️⃣  Submit Problems for a Contest"
echo "5️⃣  Exit"
echo


read -p "👉 Choose an option: " ps_choice


if [ "$ps_choice" = "1" ]; then
    read -p " 📄 Enter problem title: " problem_title
    read -p " ⚡ Problem difficulty : " problem_difficulty
    read -p " 🏷️ Enter problem tags (comma-separated): " tags
    safe_title=$(echo "$problem_title" | tr ' ' '_' )
    statement_file="./database/problem_statement/${username}_${safe_title}_statement.txt"
    touch "$statement_file"
    echo " 📝Enter problem statement (end with a single line containing 'END'):"
    echo
    while IFS= read -r line; do
    [ "$line" = "END" ] && break
    echo "$line" >> "$statement_file"
    done
    echo
    read -p "🧪🔢 Enter number of test cases: " num_cases

    for((i=1; i<=num_cases; i++)); do
        touch "./database/test_case/${username}_${safe_title}_testcase${i}.txt"
        echo "🧪🔢 Enter input for test case $i (After entering all the test case, enter the correct answer in a single line and test case file should end with 'END'):"
        echo
        while IFS= read -r line; do
        [ "$line" = "END" ] && break
        echo "$line" >> "./database/test_case/${username}_${safe_title}_testcase${i}.txt"
        done
    done
    echo "${username}_${safe_tile}|$problem_difficulty|$tags|$num_cases" >> database/problems.txt
    echo "✅ Problem created successfully!"
    sleep 1
    ./problem_setter/ps_dashboard_main.sh "$username"
elif [ "$ps_choice" = "2" ]; then
    echo "📂 Your Created Problems:"
    grep -n "^${username}_" ./database/problems.txt
    echo
    read -p "👉 Enter the number of the problem to view details: " problem_index
    content=$(sed -n "${problem_index}p" ./database/problems.txt)
    problem_name="${content%%|*}"
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
    fi
    sleep 5
    ./problem_setter/ps_dashboard_main.sh "$username"
elif [ "$ps_choice" = "3" ]; then
    echo "📋 Available Contests for Application:"
    cat -n "./database/ps_selection_in_progress.txt"
    echo
    echo "👉 Enter the number of the contests you want to apply for (space seperated) :"
    read -a contest_indicess
    for idx in "${contest_indicess[@]}"; 
    do
    contest_name=$(sed -n "${idx}p" "./database/ps_selection_in_progress.txt" | tr -d '{}' | xargs)
    if [ -n "$contest_name" ]; then
        echo "$username" >> "./database/${contest_name}_applicants.txt"
        echo "✅ Applied for $contest_name"
    fi
    done
    sleep 1
    ./problem_setter/ps_dashboard_main.sh "$username"
elif [ "$ps_choice" = "4" ]; then
    echo "📋 Available Contests for Problem Submission:"
    cat -n "./database/problem_selection_in_progress.txt"
    echo
    read -p "👉 Enter the number of the contest to submit problems for: " contest_idx
    contest_name=$(sed -n "${contest_idx}p" "./database/problem_selection_in_progress.txt" | tr -d '{}' | xargs)
    if grep -q "^${username}$" "./database/${contest_name}_ps.txt" ; then
        echo "Your created problems:"
        echo
        grep -n "^${username}_" ./database/problems.txt
        echo
        echo "👉 Enter the numbers of the problems you want to submit for $contest_name :"
        read -a problem_indices

        for idx in "${problem_indices[@]}" ;  
        do
            content=$(sed -n "${idx}p" ./database/problems.txt)
            echo "$content" >> "./database/${contest_name}_t_problems.txt"
        done
        echo "✅ Problems submitted for $contest_name"
    else
        echo "❌ You are not selected as a problem setter for this contest."
        sleep 1
        ./problem_setter/ps_dashboard_main.sh "$username"
    fi
    sleep 1
    ./problem_setter/ps_dashboard_main.sh "$username"
elif [ "${ps_choice}" = "5" ]; then
    echo "👋 Logging out..."
    sleep 1
    ./problem_setter/ps_dashboard.sh
else
    echo "❌ Invalid option!"
    sleep 1
    ./problem_setter/ps_dashboard_main.sh "$username"
fi

