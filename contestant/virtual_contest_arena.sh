#!/bin/bash

user_name="$1"

current_date=$(date +%Y-%m-%d)
current_time=$(date +%H:%M)

echo ""
echo "🏁 Virtual Contests:"
echo "--------------------"

virtual_contests=()
line_number=1

while IFS='|' read -r contest_name contest_id applicants_file ps_file t_problems f_problems contest_date start_time end_time
do
    problem_file="./database/${f_problems}"

    if [ -z "$contest_name" ] || [ ! -s "$problem_file" ]; then
        continue
    fi

    if [[ "$contest_date" < "$current_date" ]] || \
       [[ "$contest_date" = "$current_date" && "$end_time" < "$current_time" ]]; then
        echo "$line_number) $contest_name  ($contest_date $start_time - $end_time)"
        virtual_contests+=("$contest_name")
        ((line_number++))
    fi
done < ./database/contest.txt

if [ ${#virtual_contests[@]} -eq 0 ]; then
    echo ""
    echo "❌ No past contests with problems are available."
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
    bash ./contestant/virtual_contest_arena.sh "$user_name"
    exit
fi

if [ "$selection" -lt 1 ] || [ "$selection" -gt ${#virtual_contests[@]} ]; then
    echo "❌ Invalid selection."
    sleep 1
    bash ./contestant/virtual_contest_arena.sh "$user_name"
    exit
fi

selected_contest="${virtual_contests[$((selection-1))]}"

echo ""
echo "✅ Entering $selected_contest ..."
sleep 1

bash ./contestant/contest_arena.sh "$user_name" virtual "$selected_contest"