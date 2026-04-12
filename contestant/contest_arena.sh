#!/bin/bash

user_name="$1"

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

        selected_line=$(grep "^$full_name|" ./database/${contest_name}_f_problems.txt)
        num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

        verdict="Accepted"

        for ((i=1; i<=num_testcases; i++)); do
            echo ""
            echo "▶ Running test case $i/$num_testcases..."

            testcase_file="database/test_case/${full_name}_testcase${i}.txt"
            output_file="database/${user_name}/${full_name}_output${i}.txt"

            if [ ! -f "$testcase_file" ]; then
                echo "❌ Testcase file missing!"
                verdict="Judge Error"
                break
            fi

            # Parse input and output using the new format
            input_data=$(awk '/^INPUT$/{flag=1; next} /^---OUTPUT---$/{flag=0} flag' "$testcase_file")
            expected_output=$(awk '/^---OUTPUT---$/{flag=1; next} flag' "$testcase_file" | tr -d '\r')

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

    mkdir -p "./database/submissions"

    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
        version=$((version + 1))
    done

    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"
    cp "$submission_cpp" "$submission_file"

    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    mkdir -p "./database/contest_submissions"
    contest_sub_file="./database/contest_submissions/${contest_name}.txt"

    submission_time=$(date +"%H:%M:%S")

    (
        flock -x 200
        echo "${user_name}|${full_name}|${verdict}|${submission_time}" >> "$contest_sub_file"
    ) 200>"./database/contest_submissions/.lockfile"

    rm -rf "database/${user_name}"

    read -p "Press Enter to return to arena..."
}

# ── Open PDF with system default viewer ──────────────────────────────────────
open_pdf() {
    local pdf_path="$1"

    if [ ! -f "$pdf_path" ]; then
        echo "❌ PDF not found at: $pdf_path"
        read -p "Press Enter to return..."
        return 1
    fi

    # Detect available PDF viewer
    if command -v xdg-open &>/dev/null; then
        xdg-open "$pdf_path" &>/dev/null &
    elif command -v evince &>/dev/null; then
        evince "$pdf_path" &>/dev/null &
    elif command -v okular &>/dev/null; then
        okular "$pdf_path" &>/dev/null &
    elif command -v zathura &>/dev/null; then
        zathura "$pdf_path" &>/dev/null &
    elif command -v mupdf &>/dev/null; then
        mupdf "$pdf_path" &>/dev/null &
    elif command -v atril &>/dev/null; then
        atril "$pdf_path" &>/dev/null &
    else
        echo "❌ No PDF viewer found on this system."
        echo "   Install one with:  sudo apt install evince"
        echo "   PDF is at: $pdf_path"
        read -p "Press Enter to return..."
        return 1
    fi

    echo "📄 Opening PDF in your default viewer..."
    echo "   (The viewer opens in the background — return here when done)"
    read -p "Press Enter to return to arena..."
    return 0
}

contest_file="./database/contest.txt"

current_date=$(date +%Y-%m-%d)
current_time=$(date +%H:%M)

echo ""
echo "🏟️  Running Contests:"
echo "----------------------"

running_contests=()
line_number=1

while IFS="|" read -r contest_name contest_id applicants_file ps_file t_problems f_problems contest_date start_time end_time; do
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
    ./contestant/contest_arena.sh "$user_name"
    exit
fi

if [ "$selection" -lt 1 ] || [ "$selection" -gt ${#running_contests[@]} ]; then
    echo "❌ Invalid selection."
    sleep 1
    ./contestant/contest_arena.sh "$user_name"
    exit
fi

selected_contest="${running_contests[$((selection-1))]}"

registration_file="./database/registration/${selected_contest}.txt"

if [ ! -f "$registration_file" ]; then
    echo "❌ Registration file not found for this contest."
    sleep 2
    ./contestant/contest_arena.sh "$user_name"
    exit
fi

if ! grep -q "^$user_name$" "$registration_file"; then
    echo ""
    echo "⚠️  You are not registered for $selected_contest."
    echo "Please register first."
    sleep 2
    ./contestant/contest_arena.sh "$user_name"
    exit
fi

echo ""
echo "✅ Entering $selected_contest ..."
sleep 1

contest_name="$selected_contest"

problem_file="./database/${contest_name}_f_problems.txt"

contest_line=$(grep "^$contest_name|" ./database/contest.txt)
contest_end_time=$(echo "$contest_line" | cut -d'|' -f9)
contest_date=$(echo "$contest_line" | cut -d'|' -f7)

while true; do
    clear
    echo "🏟️  Contest Arena: $contest_name"
    echo "----------------------------------"

    now_epoch=$(date +%s)
    end_epoch=$(date -d "$contest_date $contest_end_time" +%s 2>/dev/null)

    if [ -n "$end_epoch" ]; then
        remaining=$((end_epoch - now_epoch))

        if [ "$remaining" -le 0 ]; then
            echo "⏰ Contest has ended."
            read -p "Press Enter to return..."
            ./contestant/contest_arena.sh "$user_name"
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

    while IFS="|" read -r full_problem_name rating tags num_tc; do
        clean_name=$(echo "$full_problem_name" | cut -d'_' -f2- | tr '_' ' ')
        echo "$line_no) $clean_name"
        problems+=("$full_problem_name")
        ((line_no++))
    done < "$problem_file"

    echo ""
    echo "Options:"
    echo "--------"
    echo "  [number]          → View problem statement PDF"
    echo "  submit            → Submit your solution"
    echo "  show_leaderboard  → View leaderboard"
    echo "  exit              → Leave arena"
    echo ""
    read -p "Enter choice: " arena_choice

    # ── Exit ─────────────────────────────────────────────────────────────────
    if [ "$arena_choice" = "exit" ]; then
        ./contestant/contest_arena.sh "$user_name"
        exit
    fi

    # ── Submit ────────────────────────────────────────────────────────────────
    if [ "$arena_choice" = "submit" ]; then
        echo ""
        echo "📌 Select problem number to submit:"
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

    # ── Leaderboard ───────────────────────────────────────────────────────────
    if [ "$arena_choice" = "show_leaderboard" ]; then
        echo ""
        echo "🏆 Generating Leaderboard..."
        echo ""

        contest_sub_file="./database/contest_submissions/${contest_name}.txt"

        if [ ! -f "$contest_sub_file" ]; then
            echo "⚠️  No submissions yet."
            read -p "Press Enter to return..."
            continue
        fi

        temp_file="./database/temp_leaderboard.txt"
        > "$temp_file"

        users=$(cut -d'|' -f1 "$contest_sub_file" | sort -u)

        for user in $users; do
            total_points=0
            total_time=0
            solved_list=""

            user_problems=$(grep "^$user|" "$contest_sub_file" | cut -d'|' -f2 | sort -u)

            for prob in $user_problems; do
                user_prob_data=$(grep "^$user|$prob|" "$contest_sub_file")

                wrong_count=0
                accepted_time=""
                solved=0

                while IFS='|' read -r u p verdict time; do
                    if [[ "$verdict" == Accepted* ]]; then
                        accepted_time="$time"
                        solved=1
                        break
                    else
                        ((wrong_count++))
                    fi
                done <<< "$user_prob_data"

                if [ $solved -eq 1 ]; then
                    contest_line=$(grep "^$contest_name|" ./database/contest.txt)
                    contest_start=$(echo "$contest_line" | awk -F'|' '{print $8}')

                    IFS=':' read -r start_h start_m <<< "$contest_start"
                    start_total=$((10#$start_h * 60 + 10#$start_m))

                    IFS=':' read -r acc_h acc_m acc_s <<< "$accepted_time"
                    acc_total=$((10#$acc_h * 60 + 10#$acc_m))

                    mins=$((acc_total - start_total))
                    [ $mins -lt 0 ] && mins=0

                    problem_points=$((1000 - wrong_count*50 - mins*2))
                    [ $problem_points -lt 0 ] && problem_points=0

                    total_points=$((total_points + problem_points))
                    total_time=$((total_time + mins))

                    prob_index=$(grep -n "^$prob|" ./database/${contest_name}_f_problems.txt | cut -d':' -f1)
                    solved_list="${solved_list}${prob_index},"
                fi
            done

            solved_list=${solved_list%,}
            echo "$user|$total_points|$total_time|$solved_list" >> "$temp_file"
        done

        echo ""
        printf "%-15s | %-10s | %-20s\n" "USER_NAME" "POINTS" "SOLVED"
        echo "--------------------------------------------------------------"

        sort -t'|' -k2,2nr -k3,3n "$temp_file" | while IFS='|' read -r u pts t sl; do
            printf "%-15s | %-10s | %-20s\n" "$u" "$pts" "$sl"
        done

        rm -f "$temp_file"
        echo ""
        read -p "Press Enter to return..."
        continue
    fi

    # ── View problem statement PDF ────────────────────────────────────────────
    if [[ "$arena_choice" =~ ^[0-9]+$ ]]; then

        if [ "$arena_choice" -lt 1 ] || [ "$arena_choice" -gt ${#problems[@]} ]; then
            echo "❌ Invalid problem number."
            sleep 1
            continue
        fi

        selected_problem="${problems[$((arena_choice-1))]}"

        # PDF is stored as database/problem_pdfs/<full_problem_name>.pdf
        pdf_file="./database/problem_pdfs/${selected_problem}.pdf"

        clear
        echo "📄 Problem: $(echo "$selected_problem" | cut -d'_' -f2- | tr '_' ' ')"
        echo "─────────────────────────────────────────"

        open_pdf "$pdf_file"
        continue
    fi

    echo "❌ Invalid input."
    sleep 1

done