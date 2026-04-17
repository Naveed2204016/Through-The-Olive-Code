#!/bin/bash

user_name="$1"
arena_mode="${2:-running}"
selected_contest_name="$3"
arena_back_script="./contestant/contest_arena.sh"
contest_submission_dir="./database/contest_submissions"

if [ "$arena_mode" = "virtual" ]; then
    arena_back_script="bash ./contestant/virtual_contest_arena.sh"
    contest_submission_dir="./database/virtual_contest_submissions"
fi



judge_submission() {

    user_name="$1"
    full_name="$2"
    contest_name="$3"

    echo ""
    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        return
    fi

    # Temporary working directory
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."
    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed."
        verdict="Compilation Error"
    else
        echo "✅ Compilation successful."
        echo ""
        echo "🧪 Starting evaluation..."

        # Get number of testcases from problem list
        selected_line=$(grep "^$full_name|" ./database/${contest_name}_f_problems.txt)
        num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

        verdict="Accepted"

        for ((i=1; i<=num_testcases; i++))
        do
        echo ""
        echo "▶ Running test case $i/$num_testcases..."

        testcase_file="database/test_case/${full_name}_testcase${i}.txt"
        output_file="database/${user_name}/${full_name}_output${i}.txt"

        if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing!"
        verdict="Judge Error"
        break
        fi

        input_data=$(sed '$d' "$testcase_file")
        expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')


        echo "$input_data" | "$submission_out" > "$output_file"
        program_output=$(cat "$output_file" | tr -d '\r')

        if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
        fi

        echo "✅ Test case $i passed"
        done
    fi

    echo ""
    echo "📢 Verdict: $verdict"

    # Save submission copy
    mkdir -p "./database/submissions"

    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
        version=$((version + 1))
    done

    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"
    cp "$submission_cpp" "$submission_file"

    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # ===============================
    # 🔥 CONTEST SUBMISSION APPEND
    # ===============================

    mkdir -p "$contest_submission_dir"
    contest_file="$contest_submission_dir/${contest_name}.txt"

    submission_time=$(date +"%H:%M:%S")

    # 🔒 Safe concurrent append
    (
        flock -x 200
        echo "${user_name}|${full_name}|${verdict}|${submission_time}" >> "$contest_file"
    ) 200>"./database/contest_submissions/.lockfile"

    # Cleanup
    rm -rf "database/${user_name}"

    read -p "Press Enter to return to arena..."
}

if [ "$arena_mode" = "running" ]; then
    contest_file="./database/contest.txt"

    current_date=$(date +%Y-%m-%d)
    current_time=$(date +%H:%M)

    echo ""
    echo "🏟️  Running Contests:"
    echo "----------------------"

    running_contests=()
    line_number=1

    while IFS="|" read -r contest_name contest_id applicants_file ps_file t_problems f_problems contest_date start_time end_time
    do
        if [ "$contest_date" = "$current_date" ]; then
            if [[ "$current_time" > "$start_time" && "$current_time" < "$end_time" ]] || \
               [[ "$current_time" = "$start_time" ]] || \
               [[ "$current_time" = "$end_time" ]]; then

                echo "$line_number) $contest_name  ($start_time - $end_time)"
                running_contests+=("$contest_name")
                ((line_number++))
            fi
        fi
    done < "$contest_file"

    if [ ${#running_contests[@]} -eq 0 ]; then
        echo ""
        echo "❌ No running contests right now."
        read -p "Press Enter to go back..."
        ./contestant/contestant_dashboard_main.sh "$user_name"
        exit
    fi

    echo ""
    read -p "Enter contest line number or write back to go back to main dashboard: " selection

    if [ "$selection" = "back" ]; then
        ./contestant/contestant_dashboard_main.sh "$user_name"
        exit
    fi

    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo "❌ Invalid input."
        sleep 1
        $arena_back_script "$user_name"
        exit
    fi

    if [ "$selection" -lt 1 ] || [ "$selection" -gt ${#running_contests[@]} ]; then
        echo "❌ Invalid selection."
        sleep 1
        $arena_back_script "$user_name"
        exit
    fi

    selected_contest="${running_contests[$((selection-1))]}"

    registration_file="./database/registration/${selected_contest}.txt"

    if [ ! -f "$registration_file" ]; then
        echo "❌ Registration file not found for this contest."
        sleep 2
        $arena_back_script "$user_name"
        exit
    fi

    if ! grep -q "^$user_name$" "$registration_file"; then
        echo ""
        echo "⚠️  You are not registered for $selected_contest."
        echo "Please register first."
        sleep 2
        $arena_back_script "$user_name"
        exit
    fi

    echo ""
    echo "✅ Entering $selected_contest ..."
    sleep 1

    contest_name="$selected_contest"
else
    contest_name="$selected_contest_name"
    if [ -z "$contest_name" ]; then
        echo "❌ No contest selected."
        exit 1
    fi
fi

# ===============================
# ENTER CONTEST ARENA
# ===============================

problem_file="./database/${contest_name}_f_problems.txt"
virtual_mode=0

contest_line=$(grep "^$contest_name|" ./database/contest.txt)

if [ "$arena_mode" = "virtual" ]; then
    virtual_mode=1
    contest_date=$(date +%Y-%m-%d)
    original_start_time=$(echo "$contest_line" | cut -d'|' -f8)
    original_end_time=$(echo "$contest_line" | cut -d'|' -f9)

    original_start_epoch=$(date -d "$(echo "$contest_line" | cut -d'|' -f7) $original_start_time" +%s 2>/dev/null)
    original_end_epoch=$(date -d "$(echo "$contest_line" | cut -d'|' -f7) $original_end_time" +%s 2>/dev/null)

    contest_duration=$((original_end_epoch - original_start_epoch))
    if [ "$contest_duration" -lt 0 ]; then
        contest_duration=0
    fi

    contest_start_epoch=$(date +%s)
    contest_end_epoch=$((contest_start_epoch + contest_duration))
    contest_end_time=$(date -d "@$contest_end_epoch" +%H:%M 2>/dev/null)
else
    contest_end_time=$(echo "$contest_line" | cut -d'|' -f9)
    contest_date=$(echo "$contest_line" | cut -d'|' -f7)
fi

while true
do
    clear
    echo "🏟️  Contest Arena: $contest_name"
    echo "----------------------------------"

    # Calculate remaining time
    now_epoch=$(date +%s)
    if [ "$virtual_mode" -eq 1 ]; then
        end_epoch="$contest_end_epoch"
    else
        end_epoch=$(date -d "$contest_date $contest_end_time" +%s 2>/dev/null)
    fi

    if [ -n "$end_epoch" ]; then
        remaining=$((end_epoch - now_epoch))

        if [ "$remaining" -le 0 ]; then
            echo "⏰ Contest has ended."
            read -p "Press Enter to return..."
            $arena_back_script "$user_name"
            exit
        fi

        hours=$((remaining / 3600))
        minutes=$(((remaining % 3600) / 60))
        seconds=$((remaining % 60))

        printf "⏳ Remaining Time: %02d:%02d:%02d\n" $hours $minutes $seconds
    fi

    echo ""
    echo "📚 Problems:"
    echo "-------------"

    problems=()
    line_no=1

    while IFS="|" read -r full_problem_name rating tags solved
    do
        # Extract clean name (remove first part before first underscore)
        clean_name=$(echo "$full_problem_name" | cut -d'_' -f2-)

        echo "$line_no) $clean_name"
        problems+=("$full_problem_name")
        ((line_no++))

    done < "$problem_file"

    echo ""
    echo "Options:"
    echo "--------"
    echo "Type problem number to view statement"
    echo "submit"
    echo "show_leaderboard"
    echo "exit"

    echo ""
    read -p "Enter choice: " arena_choice

    # Exit Arena
    if [ "$arena_choice" = "exit" ]; then
        $arena_back_script "$user_name"
        exit
    fi

    # Submit option (logic later)
    if [ "$arena_choice" = "submit" ]; then
        echo ""
        echo "📌 Select problem number to submit: "
        read -p "Problem number: " prob_num

        if ! [[ "$prob_num" =~ ^[0-9]+$ ]] || \
        [ "$prob_num" -lt 1 ] || \
        [ "$prob_num" -gt ${#problems[@]} ]; then
        echo "❌ Invalid problem number."
        sleep 1
        continue
        fi

        full_problem_name="${problems[$((prob_num-1))]}"

        judge_submission "$user_name" "$full_problem_name" "$contest_name"

        continue
        fi

    # Leaderboard option (logic later)
    if [ "$arena_choice" = "show_leaderboard" ]; then
        
    echo ""
    echo "🏆 Generating Leaderboard..."
    echo ""

    contest_file="$contest_submission_dir/${contest_name}.txt"

    if [ ! -f "$contest_file" ]; then
        echo "⚠ No submissions yet."
        read -p "Press Enter to return..."
        continue
    fi

    # Temporary file
    temp_file="./database/temp_leaderboard.txt"
    > "$temp_file"

    # Extract unique users
    users=$(cut -d'|' -f1 "$contest_file" | sort -u)

    for user in $users
    do
        total_points=0
        total_time=0
        solved_list=""

        # Get all problems attempted by this user
        problems=$(grep "^$user|" "$contest_file" | cut -d'|' -f2 | sort -u)

        for prob in $problems
        do
            user_prob_data=$(grep "^$user|$prob|" "$contest_file")

            wrong_count=0
            accepted_time=""
            solved=0

            while IFS='|' read -r u p verdict time
            do
                if [[ "$verdict" == Accepted* ]]; then
                    accepted_time="$time"
                    solved=1
                    break
                else
                    ((wrong_count++))
                fi
            done <<< "$user_prob_data"

            if [ $solved -eq 1 ]; then

                # Get contest start time from contest.txt
                if [ "$virtual_mode" -eq 1 ]; then
                    contest_start=$(date -d "@$contest_start_epoch" +%H:%M 2>/dev/null)
                else
                    contest_line=$(grep "^$contest_name|" ./database/contest.txt)
                    contest_start=$(echo "$contest_line" | awk -F'|' '{print $8}')
                fi

                IFS=':' read -r start_h start_m <<< "$contest_start"
                start_total=$((10#$start_h * 60 + 10#$start_m))

                IFS=':' read -r acc_h acc_m acc_s <<< "$accepted_time"
                acc_total=$((10#$acc_h * 60 + 10#$acc_m))

                minutes=$((acc_total - start_total))

                # Safety check
                if [ $minutes -lt 0 ]; then
                minutes=0
                fi

                problem_points=$((1000 - wrong_count*50 - minutes*2))
                if [ $problem_points -lt 0 ]; then
                    problem_points=0
                fi

                total_points=$((total_points + problem_points))
                total_time=$((total_time + minutes))

                # Append problem index (extract number from problem list)
                prob_index=$(grep -n "^$prob|" ./database/${contest_name}_f_problems.txt | cut -d':' -f1)
                solved_list="${solved_list}${prob_index},"
            fi

        done

        # Remove trailing comma
        solved_list=${solved_list%,}

        echo "$user|$total_points|$total_time|$solved_list" >> "$temp_file"

    done

    echo ""
    printf "%-15s | %-10s | %-20s\n" "USER_NAME" "POINTS" "SOLVED"
    echo "--------------------------------------------------------------"

    sort -t'|' -k2,2nr -k3,3n "$temp_file" | while IFS='|' read -r u pts t sl
    do
        printf "%-15s | %-10s | %-20s\n" "$u" "$pts" "$sl"
    done

    rm -f "$temp_file"

    echo ""
    read -p "Press Enter to return..."
    continue
    fi

    # If numeric → show problem statement
    if [[ "$arena_choice" =~ ^[0-9]+$ ]]; then

        if [ "$arena_choice" -lt 1 ] || [ "$arena_choice" -gt ${#problems[@]} ]; then
            echo "❌ Invalid problem number."
            sleep 1
            continue
        fi

        selected_problem="${problems[$((arena_choice-1))]}"
        statement_file="./database/problem_statement/${selected_problem}_statement.txt"

        clear
        echo "📄 Problem Statement"
        echo "----------------------"

        if [ -f "$statement_file" ]; then
            cat "$statement_file"
        else
            echo "❌ Problem statement file not found."
        fi

        echo ""
        read -p "Press Enter to return to arena..."
        continue
    fi

    echo "❌ Invalid input."
    sleep 1

done