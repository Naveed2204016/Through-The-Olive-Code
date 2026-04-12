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
    read -p " 🏷️  Enter problem tags (comma-separated): " tags
    safe_title=$(echo "$problem_title" | tr ' ' '_')

    tex_dir="./database/problem_tex"
    pdf_dir="./database/problem_pdfs"
    tc_dir="./database/test_case"
    mkdir -p "$tex_dir" "$pdf_dir" "$tc_dir"

    tex_file="${tex_dir}/${username}_${safe_title}.tex"

    echo " 📝 Enter problem statement in LaTeX (end with a single line 'END'):"
    echo "    (You can use math: \$x^2\$, environments: \\begin{itemize}, etc.)"
    echo

    statement_body=""
    while IFS= read -r line; do
        [ "$line" = "END" ] && break
        statement_body+="$line"$'\n'
    done

    echo
    read -p "🧪🔢 Enter number of test cases: " num_cases

    # Collect test cases
    for((i=1; i<=num_cases; i++)); do
        tc_file="${tc_dir}/${username}_${safe_title}_testcase${i}.txt"

        echo "🧪 Enter INPUT for test case $i (end with 'END'):"
        input_body=""
        while IFS= read -r line; do
            [ "$line" = "END" ] && break
            input_body+="$line"$'\n'
        done

        echo "✅ Enter OUTPUT for test case $i (end with 'END'):"
        output_body=""
        while IFS= read -r line; do
            [ "$line" = "END" ] && break
            output_body+="$line"$'\n'
        done

        # Save both in the file with a separator
        printf "INPUT\n%s---OUTPUT---\n%s" "$input_body" "$output_body" > "$tc_file"
    done

    # Build LaTeX test case tables
    testcase_latex=""
    for((i=1; i<=num_cases; i++)); do
        tc_file="${tc_dir}/${username}_${safe_title}_testcase${i}.txt"

        tc_input=$(awk '/^INPUT$/{flag=1; next} /^---OUTPUT---$/{flag=0} flag' "$tc_file")
        tc_output=$(awk '/^---OUTPUT---$/{flag=1; next} flag' "$tc_file")

        # Escape LaTeX special characters
        tc_input_escaped=$(echo "$tc_input" | sed \
            's/\\/\\textbackslash{}/g
             s/_/\\_/g
             s/\^/\\^{}/g
             s/&/\\&/g
             s/%/\\%/g
             s/#/\\#/g
             s/{/\\{/g
             s/}/\\}/g')

        tc_output_escaped=$(echo "$tc_output" | sed \
            's/\\/\\textbackslash{}/g
             s/_/\\_/g
             s/\^/\\^{}/g
             s/&/\\&/g
             s/%/\\%/g
             s/#/\\#/g
             s/{/\\{/g
             s/}/\\}/g')

        # Convert each line to LaTeX newline inside minipage
        tc_input_lines=$(echo "$tc_input_escaped" | awk 'NR>1{print prev " \\\\"} {prev=$0} END{print prev}')
        tc_output_lines=$(echo "$tc_output_escaped" | awk 'NR>1{print prev " \\\\"} {prev=$0} END{print prev}')

        testcase_latex+="\\vspace{0.5em}
\\noindent\\textbf{Example $i}\\\\[0.3em]
\\noindent
\\begin{tabular}{|p{0.45\\textwidth}|p{0.45\\textwidth}|}
\\hline
\\textbf{Input} & \\textbf{Output} \\\\
\\hline
\\begin{minipage}[t]{0.45\\textwidth}
\\vspace{4pt}
{\\ttfamily\\small $tc_input_lines}
\\vspace{4pt}
\\end{minipage}
&
\\begin{minipage}[t]{0.45\\textwidth}
\\vspace{4pt}
{\\ttfamily\\small $tc_output_lines}
\\vspace{4pt}
\\end{minipage}
\\\\
\\hline
\\end{tabular}
\\vspace{0.5em}

"
    done

    # Write the full .tex file
    cat > "$tex_file" <<LATEX
\\documentclass[12pt]{article}
\\usepackage{amsmath, amssymb, geometry, fancyhdr, hyperref, array}
\\geometry{margin=1in}

\\pagestyle{fancy}
\\fancyhf{}
\\rhead{\\textbf{Difficulty:} $problem_difficulty}
\\lhead{\\textbf{Tags:} $tags}
\\cfoot{\\thepage}

\\begin{document}

\\begin{center}
    {\\LARGE \\textbf{$problem_title}} \\\\[0.4em]
    {\\large Set by: \\texttt{$username}}
\\end{center}

\\vspace{1em}
\\hrule
\\vspace{1em}

\\section*{Problem Statement}
$statement_body

\\section*{Examples}
$testcase_latex

\\end{document}
LATEX

    echo
    echo " 🔨 Compiling LaTeX to PDF..."
    if latexmk -pdf -interaction=nonstopmode -output-directory="$pdf_dir" "$tex_file" > /dev/null 2>&1; then
        echo " ✅ PDF compiled successfully → $pdf_dir/${username}_${safe_title}.pdf"
    else
        echo " ⚠️  LaTeX compilation failed. Check $tex_file for errors."
        echo "    Run: latexmk -pdf $tex_file  to see detailed errors."
    fi

    # Clean up auxiliary files
    latexmk -c -output-directory="$pdf_dir" "$tex_file" > /dev/null 2>&1

    echo "${username}_${safe_title}|$problem_difficulty|$tags|$num_cases" >> database/problems.txt
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

    echo
    echo "📄 Problem: $problem_name"
    echo "─────────────────────────────────"

    # Show PDF path if exists
    pdf_path="./database/problem_pdfs/${problem_name}.pdf"
    if [ -f "$pdf_path" ]; then
        echo "📑 PDF available at: $pdf_path"
    fi

    echo
    echo "Would you like to view the test cases? (y/n)"
    read view_cases
    if [ "$view_cases" = "y" ]; then
        num_cases=$(echo "$content" | cut -d '|' -f 4)
        for((i=1; i<=num_cases; i++)); do
            tc_file="./database/test_case/${problem_name}_testcase${i}.txt"
            echo "─── Test Case $i ───────────────────"
            echo "📥 Input:"
            awk '/^INPUT$/{flag=1; next} /^---OUTPUT---$/{flag=0} flag' "$tc_file"
            echo "📤 Output:"
            awk '/^---OUTPUT---$/{flag=1; next} flag' "$tc_file"
            echo
        done
    fi
    sleep 5
    ./problem_setter/ps_dashboard_main.sh "$username"

elif [ "$ps_choice" = "3" ]; then
    echo "📋 Available Contests for Application:"
    cat -n "./database/ps_selection_in_progress.txt"
    echo
    echo "👉 Enter the number of the contests you want to apply for (space separated):"
    read -a contest_indicess
    for idx in "${contest_indicess[@]}"; do
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
    if grep -q "^${username}$" "./database/${contest_name}_ps.txt"; then
        echo "Your created problems:"
        echo
        grep -n "^${username}_" ./database/problems.txt
        echo
        echo "👉 Enter the numbers of the problems you want to submit for $contest_name:"
        read -a problem_indices
        for idx in "${problem_indices[@]}"; do
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