#!/bin/bash
clear

user_name="$1"


sorting_and_searching()
{
    echo ""
    echo "🔎📊 Here are the Sorting and Searching problems:"
    echo "------------------------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="sorting" || topics[i]=="searching")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No sorting/searching problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt


    # Cleanup user temp directory
    rm -rf "database/${user_name}"    
}

dp()
{
    echo ""
    echo "🔎📊 Here are the Dynammic Programming problems:"
    echo "-------------------------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="dp")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Dynamic Programming problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}

greedy()
{
    echo ""
    echo "🔎📊 Here are the Greedy problems:"
    echo "-----------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="greedy")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Greedy problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}

graph()
{
    echo ""
    echo "🔎📊 Here are the Graph problems:"
    echo "----------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="graph")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Graph problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}

range_query()
{
    echo ""
    echo "🔎📊 Here are the Range Query problems:"
    echo "----------------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="range_query")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Range Query problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}

tree()
{
    echo ""
    echo "🔎📊 Here are the Tree problems:"
    echo "---------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="tree")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Tree problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}


bit_manipulation()
{
    echo ""
    echo "🔎📊 Here are the Bit Manipulation problems:"
    echo "---------------------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="bit_manipulation")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Bit Manipulation problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}

mathametics()
{
    echo ""
    echo "🔎📊 Here are the Mathametics problems:"
    echo "----------------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="mathametics")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Mathametics problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}


string1()
{
    echo ""
    echo "🔎📊 Here are the String problems:"
    echo "-----------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="string")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No String problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}

geo()
{
    echo ""
    echo "🔎📊 Here are the Geometry problems:"
    echo "-------------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="geometry")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Geometry problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}

combinatorics()
{
    echo ""
    echo "🔎📊 Here are the Combinatorics problems:"
    echo "------------------------------------------"

    problems_file="database/problems.txt"
    filtered_file="database/.filtered_problems_tmp.txt"

    # Filter problems containing sorting or searching in 3rd column
    awk -F'|' '
    {
        split($3, topics, ",")
        for(i in topics)
        {
            if(topics[i]=="combinatorics")
            {
                print $0
                break
            }
        }
    }' "$problems_file" > "$filtered_file"

    if [ ! -s "$filtered_file" ]; then
        echo "❌ No Combinatorics problems found."
        return
    fi

    # Display numbered list
    cat -n "$filtered_file" | while read num line
    do
        full_name=$(echo "$line" | awk -F'|' '{print $1}')
        difficulty=$(echo "$line" | awk -F'|' '{print $2}')

        # Extract problem name (remove username prefix)
        problem_name="${full_name#*_}"

        echo "$num) $problem_name | Difficulty: $difficulty"
    done

    echo ""
    read -p "👉 Enter the problem number you want to solve: " idx

    selected_line=$(sed -n "${idx}p" "$filtered_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$filtered_file"
        return
    fi

    full_name=$(echo "$selected_line" | awk -F'|' '{print $1}')
    problem_name="${full_name#*_}"

    statement_file="database/problem_statement/${full_name}_statement.txt"

    echo ""
    echo "📄 Problem Statement:"
    echo "----------------------"

    if [ -f "$statement_file" ]; then
        cat "$statement_file"
    else
        echo "❌ Problem statement file not found."
        rm -f "$filtered_file"
        return
    fi

    echo ""
    read -p "🚀 Press ENTER to submit your solution..."

    read -p "📂 Enter full path of your .cpp solution file: " solution_path

    if [ ! -f "$solution_path" ]; then
        echo "❌ File not found."
        rm -f "$filtered_file"
        return
    fi

    # Create user directory if not exists
    mkdir -p "database/${user_name}"

    submission_cpp="database/${user_name}/${full_name}_submission.cpp"
    submission_out="database/${user_name}/${full_name}_submission.out"

    # Copy submission
    cp "$solution_path" "$submission_cpp"

    echo "⚙️ Compiling your solution..."

    g++ "$submission_cpp" -o "$submission_out"

    if [ $? -eq 0 ]; then
        echo "✅ Compilation successful."
    else
        echo "❌ Compilation failed."
    fi

    # Cleanup temporary file
    rm -f "$filtered_file"



    # Extract number of testcases
    num_testcases=$(echo "$selected_line" | awk -F'|' '{print $4}')

    echo ""
    echo "🧪 Starting evaluation..."

    verdict="Accepted"

    for ((i=1; i<=num_testcases; i++))
    do
    echo "▶ Running on test case $i..."

    testcase_file="database/test_case/${full_name}_testcase${i}.txt"
    output_file="database/${user_name}/${full_name}_output${i}.txt"

    if [ ! -f "$testcase_file" ]; then
        echo "❌ Testcase file missing: $testcase_file"
        verdict="Judge Error"
        break
    fi

    # Extract input (all except last line)
    input_data=$(sed '$d' "$testcase_file")

    # Extract expected output (last line)
    expected_output=$(tail -n 1 "$testcase_file" | tr -d '\r')

    # Run program and store output
    echo "$input_data" | "$submission_out" > "$output_file"

    # Read program output
    program_output=$(cat "$output_file" | tr -d '\r')

    # Compare outputs
    if [ "$program_output" != "$expected_output" ]; then
        echo "❌ Wrong Answer on test case $i"
        verdict="Wrong Answer on test case $i"
        break
    fi

    echo "✅ Test case $i passed"

    done

    echo ""

    if [ "$verdict" = "Accepted" ]; then
    echo "🎉 Accepted"
    else
    echo "⚠ Verdict: $verdict"
    fi

    # Save submission permanently
    # Ensure submissions directory exists
    mkdir -p "./database/submissions"

    # Determine next submission version
    version=1
    while [ -f "./database/submissions/${user_name}_${full_name}_submission${version}.txt" ]; do
    version=$((version + 1))
    done

    # Set submission filename
    submission_file="./database/submissions/${user_name}_${full_name}_submission${version}.txt"

    # Create the .txt file and copy cpp into it
    touch "$submission_file"
    cp "$submission_cpp" "$submission_file"

    # Log verdict with correct version
    echo "${user_name}_${full_name}_submission${version}.cpp | $verdict" >> database/logs.txt

    # Cleanup user temp directory
    rm -rf "database/${user_name}"
}

info=$(grep "^${user_name}|" "./database/contestant.txt")
rating=$(echo "$info" | awk -F'|' '{print $3}')

#echo "Welcome ${user_name}. Your current rating is ${rating}"
echo "========================================"
echo "      ⚔️ Contestant DASHBOARD  ⚔️      "
echo "========================================"
echo
echo "1️⃣  Solve Topic Wise Problems"
echo "2️⃣  View Past Submissions"
echo "3️⃣  Register for a Contest"
echo "4️⃣  Participate in a Running Contest"
echo "5️⃣  View leaderboard of past contests"
echo "6️⃣  Exit"
echo

read -p "👉 Choose an option: " choice

if [ "$choice" = "1" ]; then
    echo "1. Sorting and Searching"
    echo "2. Dynammic Programming"
    echo "3. Greedy"
    echo "4. Graph"
    echo "5. Range Queries"
    echo "6. Tree"
    echo "7. Bit Manipulation"
    echo "8. Mathametics"
    echo "9. String"
    echo "10. Geometry"
    echo "11. Combinatorics"

    read -p "👉 Choose a topic: (1/2/3..) " topic

    case $topic in
    1)
    sorting_and_searching
    ;;
    2)
    dp
    ;;
    3)
    greedy
    ;;
    4)
    graph
    ;;
    5)
    range_query
    ;;
    6)
    tree
    ;;
    7)
    bit_manipulation
    ;;
    8)
    mathametics
    ;;
    9)
    string1
    ;;
    10)
    geo 
    ;;
    11)
    combinatorics 
    ;;
    *)
    echo "❌ Invalid option"
    sleep 1
    ./contestant/contestant_dashboard_main.sh
    ;;
    esac
    sleep 2
    ./contestant/contestant_dashboard_main.sh
elif [ "$choice" = "2" ]; then
    echo ""
    echo "📜 Here are your past submissions:"
    echo "----------------------------------"

    logs_file="./database/logs.txt"
    temp_file="./database/.user_submissions_tmp.txt"


    # Extract only this user's submissions and reverse order (latest first)
    grep "^${user_name}_" "$logs_file" | tac > "$temp_file"

    if [ ! -s "$temp_file" ]; then
        echo "❌ No submissions found."
        echo ""
        read -p "Press ENTER to return to dashboard..."
        ./contestant/contestant_dashboard_main.sh
        return
    fi

    # Show numbered list
    cat -n "$temp_file"

    echo ""
    read -p "👉 Enter submission number to view source code (or press ENTER to return): " choice

    # If user presses ENTER without input
    if [ -z "$choice" ]; then
        rm -f "$temp_file"
        ./contestant/contestant_dashboard_main.sh
        return
    fi

    selected_line=$(sed -n "${choice}p" "$temp_file")

    if [ -z "$selected_line" ]; then
        echo "❌ Invalid selection."
        rm -f "$temp_file"
        read -p "Press ENTER to return to dashboard..."
        ./contestant/contestant_dashboard_main.sh
        return
    fi

    # Extract submission name (before |)
    submission_name=$(echo "$selected_line" | awk '{print $1}')

    # Convert .cpp name → .txt name
    submission_txt="${submission_name%.cpp}.txt"

    submission_path="./database/submissions/$submission_txt"

    echo ""
    echo "📄 Source Code:"
    echo "---------------"

    if [ -f "$submission_path" ]; then
        cat "$submission_path"
    else
        echo "❌ Source file not found."
    fi

    rm -f "$temp_file"

    echo ""
    read -p "Press ENTER to return to dashboard..."

    ./contestant/contestant_dashboard_main.sh
elif [ "$choice" = "3" ]; then
    echo "🚀 Upcoming contests"
    echo

    file="./database/contest.txt"
    now=$(date +"%Y-%m-%d %H:%M")

    line_no=0

    while IFS='|' read -r name total app ps tp fp date start end
    do
    line_no=$((line_no+1))

    # Combine date and ending time
    end_datetime="$date $end"

    # Convert both to seconds for comparison
    end_sec=$(date -d "$end_datetime" +%s 2>/dev/null)
    now_sec=$(date -d "$now" +%s)

    if [ "$end_sec" -gt "$now_sec" ]; then
        echo "$line_no) $name"
    fi

    done < "$file"
    echo ""
    read -p "👉 Choose a contest to register: " con

    contest_line=$(sed -n "${con}p" "./database/contest.txt")

    # Check if line exists
    if [ -z "$contest_line" ]; then
    echo "❌ Invalid selection."
    exit 1
    fi

    # Extract contest name (before first |)
    contest_name=$(echo "$contest_line" | cut -d'|' -f1)

    contest_file="./database/registration/${contest_name}.txt"

    # Check if contest file exists
    if [ ! -f "$contest_file" ]; then
    echo "❌ Contest file not found."
    exit 1
    fi

    # Prevent duplicate registration
    if grep -q "^$user_name$" "$contest_file"; then
    echo "⚠️ You are already registered in $contest_name."
    else
    echo "$user_name" >> "$contest_file"
    echo "✅ Registration successful for $contest_name!"
    fi
    sleep 1
    ./contestant/contestant_dashboard_main.sh "$user_name"
elif [ "$choice" = "4" ]; then
    ./contestant/contest_arena.sh "$user_name"
elif [ "$choice" = "5" ]; then
    echo ""
    echo "🏁 Finished Contests:"
    echo ""

    current_date=$(date +%Y-%m-%d)
    current_time=$(date +%H:%M)

    finished_contests=()
    line_numbers=()
    index=1

    while IFS="|" read -r contest_name contest_id applicants ps t_problems f_problems contest_date start_time end_time
    do
    # Skip empty or malformed lines
    [[ -z "$contest_name" || -z "$contest_date" || -z "$start_time" || -z "$end_time" ]] && continue

    if [[ "$contest_date" < "$current_date" ]] || \
       [[ "$contest_date" = "$current_date" && "$end_time" < "$current_time" ]]; then

        echo "$index) $contest_name  ($contest_date $start_time-$end_time)"
        finished_contests+=("$contest_name")
        line_numbers+=("$index")
        ((index++))
    fi
    done < ./database/contest.txt

    if [ ${#finished_contests[@]} -eq 0 ]; then
        echo "⚠ No finished contests available."
        read -p "Press Enter to return..."
        ./contestant/contestant_dashboard_main.sh "$user_name"
    fi

    echo ""
    read -p "Select contest by number: " select_num

    if ! [[ "$select_num" =~ ^[0-9]+$ ]] || \
       [ "$select_num" -lt 1 ] || \
       [ "$select_num" -gt ${#finished_contests[@]} ]; then
        echo "❌ Invalid selection."
        sleep 1
        ./contestant/contestant_dashboard_main.sh "$user_name"
    fi

    contest_name="${finished_contests[$((select_num-1))]}"

    mkdir -p ./database/final_leaderboard
    final_file="./database/final_leaderboard/${contest_name}.txt"

    # ============================
    # If leaderboard already exists
    # ============================

    if [ -f "$final_file" ] && [ -s "$final_file" ]; then
        echo ""
        echo "🏆 Final Leaderboard for $contest_name"
        echo "---------------------------------------------"
        cat "$final_file"
        echo ""
        read -p "Press Enter to return..."
        ./contestant/contestant_dashboard_main.sh "$user_name"
    fi

    # =====================================
    # Otherwise compute and store it
    # =====================================

    echo ""
    echo "🧮 Computing final leaderboard..."

    contest_file="./database/contest_submissions/${contest_name}.txt"

    if [ ! -f "$contest_file" ]; then
        echo "⚠ No submissions found."
        read -p "Press Enter to return..."
        ./contestant/contestant_dashboard_main.sh "$user_name"
    fi

    temp_file="./database/temp_leaderboard.txt"
    > "$temp_file"

    users=$(cut -d'|' -f1 "$contest_file" | sort -u)

    while IFS="|" read -r cname cid applicants ps tprob fprob cdate cstart cend
    do
        if [ "$cname" = "$contest_name" ]; then
            contest_start="$cstart"
            break
        fi
    done < ./database/contest.txt

    IFS=':' read -r start_h start_m <<< "$contest_start"
    start_total=$((10#$start_h * 60 + 10#$start_m))

    for user in $users
    do
        total_points=0
        total_time=0
        solved_list=""

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

                IFS=':' read -r acc_h acc_m acc_s <<< "$accepted_time"
                acc_total=$((10#$acc_h * 60 + 10#$acc_m))

                minutes=$((acc_total - start_total))
                if [ $minutes -lt 0 ]; then
                    minutes=0
                fi

                problem_points=$((1000 - wrong_count*50 - minutes*2))
                if [ $problem_points -lt 0 ]; then
                    problem_points=0
                fi

                total_points=$((total_points + problem_points))
                total_time=$((total_time + minutes))

                prob_index=$(grep -n "^$prob|" ./database/${contest_name}_f_problems.txt | cut -d':' -f1)
                solved_list="${solved_list}${prob_index},"
            fi

        done

        solved_list=${solved_list%,}

        echo "$user|$total_points|$total_time|$solved_list" >> "$temp_file"

    done

    # Write sorted leaderboard permanently
    printf "%-15s | %-10s | %-20s\n" "USER_NAME" "POINTS" "SOLVED" > "$final_file"
    echo "--------------------------------------------------------------" >> "$final_file"

    sort -t'|' -k2,2nr -k3,3n "$temp_file" | while IFS='|' read -r u pts t sl
    do
        printf "%-15s | %-10s | %-20s\n" "$u" "$pts" "$sl" >> "$final_file"
    done

    rm -f "$temp_file"

    echo ""
    echo "🏆 Final Leaderboard for $contest_name"
    echo "---------------------------------------------"
    cat "$final_file"

    echo ""
    read -p "Press Enter to return..."
    ./contestant/contestant_dashboard_main.sh "$user_name"
elif [ "$choice" = "6" ]; then
    sleep 1
    ./contestant/contestant_dashboard.sh
fi



