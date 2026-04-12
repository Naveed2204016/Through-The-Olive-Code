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
    read -p " ⚡ Problem difficulty (e.g. 800, 1200, 2000): " problem_difficulty
    read -p " 🏷️  Enter problem tags (comma-separated): " tags
    read -p " 🧪 How many example test cases will you add? " num_cases

    # Validate num_cases
    if ! [[ "$num_cases" =~ ^[1-9][0-9]*$ ]]; then
        echo "❌ Invalid number of test cases. Must be a positive integer."
        sleep 2
        ./problem_setter/ps_dashboard_main.sh "$username"
        exit 1
    fi

    safe_title=$(echo "$problem_title" | tr ' ' '_')

    tex_dir="./database/problem_tex"
    pdf_dir="./database/problem_pdfs"
    tc_dir="./database/test_case"
    mkdir -p "$tex_dir" "$pdf_dir" "$tc_dir"

    tex_file="${tex_dir}/${username}_${safe_title}.tex"

# ── Build test case table blocks dynamically ─────────────────────────────
    testcase_temp="./database/problem_tex/${username}_${safe_title}_tc_temp.tex"
    > "$testcase_temp"

    for((i=1; i<=num_cases; i++)); do
        cat >> "$testcase_temp" << 'TCBLOCK'
\vspace{0.6em}
TCBLOCK
        echo "\\noindent\\textbf{Example ${i}}\\\\[0.3em]" >> "$testcase_temp"
        cat >> "$testcase_temp" << 'TCBLOCK'
\noindent
\begin{tabular}{|p{0.45\textwidth}|p{0.45\textwidth}|}
\hline
\textbf{Input} & \textbf{Output} \\
\hline
\begin{minipage}[t]{0.45\textwidth}
\vspace{4pt}
{\ttfamily\small
% Type input below — end each line with \\
% Example:  5 \\
%           1 2 3 4 5 \\
REPLACE\_WITH\_INPUT \\
}
\vspace{4pt}
\end{minipage}
&
\begin{minipage}[t]{0.45\textwidth}
\vspace{4pt}
{\ttfamily\small
% Type output below — end each line with \\
% Example:  15 \\
REPLACE\_WITH\_OUTPUT \\
}
\vspace{4pt}
\end{minipage}
\\
\hline
\end{tabular}
\vspace{0.5em}

TCBLOCK
    done

    # ── Write the main .tex skeleton (no variable expansion issues) ──────────
    cat > "$tex_file" << 'LATEX'
% ╔═══════════════════════════════════════════════════════════════════════════╗
% ║              COMPETITIVE PROGRAMMING — PROBLEM TEMPLATE                  ║
% ║                                                                           ║
% ║  HOW TO USE THIS FILE:                                                    ║
% ║  1. Read each section — % comments explain what to write and where.      ║
% ║  2. Delete placeholder comments when you fill in real content.           ║
% ║  3. Do NOT delete \begin{document}, \end{document}, or any              ║
% ║     \begin{tabular} / \end{tabular} blocks.                              ║
% ║  4. Save and quit — the system compiles this to PDF automatically.       ║
% ║                                                                           ║
% ║  USEFUL LATEX MATH SYNTAX:                                                ║
% ║    Inline math   : $x^2 + y^2$                                           ║
% ║    Display math  : \[ x = \frac{-b \pm \sqrt{b^2-4ac}}{2a} \]           ║
% ║    Summation     : $\sum_{i=1}^{n} a_i$                                  ║
% ║    Subscript     : $a_{i,j}$    Superscript : $10^9$                     ║
% ║    Floor / Ceil  : $\lfloor x \rfloor$   $\lceil x \rceil$               ║
% ╚═══════════════════════════════════════════════════════════════════════════╝

\documentclass[12pt]{article}
\usepackage{amsmath, amssymb}
\usepackage{geometry}
\usepackage{fancyhdr}
\usepackage{array}
\usepackage{enumitem}
\usepackage{parskip}
\usepackage{mdframed}
\usepackage{lmodern}
\usepackage[T1]{fontenc}
\usepackage{hyperref}

\geometry{margin=1in}
\pagestyle{fancy}
\fancyhf{}
\cfoot{\thepage}
\renewcommand{\headrulewidth}{0.4pt}

\newmdenv[linecolor=black, linewidth=1pt, leftmargin=10pt,
          rightmargin=10pt, skipabove=6pt, skipbelow=6pt]{note}

LATEX

    # ── Inject dynamic values (difficulty, tags, title, username) ────────────
    cat >> "$tex_file" << LATEX
\\rhead{\\textbf{Difficulty:} $problem_difficulty}
\\lhead{\\textbf{Tags:} $tags}

\\begin{document}

\\begin{center}
    {\\LARGE \\textbf{$problem_title}} \\\\[0.4em]
    {\\large Set by: \\texttt{$username}}
\\end{center}
\\vspace{0.5em}
\\hrule
\\vspace{1em}

LATEX

    # ── Append the static problem statement section ──────────────────────────
    cat >> "$tex_file" << 'LATEX'
% ════════════════════════════════════════════════════════════════════════════
%  PROBLEM STATEMENT
%  Write the full problem description here. Include:
%    - The scenario / story
%    - What the contestant must find or compute
%    - Input format   e.g. "The first line contains integer N..."
%    - Output format  e.g. "Print the maximum sum..."
%    - Constraints    e.g. $1 \leq N \leq 10^5$
%
%  TIPS:
%    - Always use math mode for numbers/variables: $N$, $a_i$, $10^9$
%    - Bullet list  : \begin{itemize} \item ... \end{itemize}
%    - Numbered list: \begin{enumerate} \item ... \end{enumerate}
%    - Hint box     : \begin{note} your note here \end{note}
%
%  EXAMPLE STRUCTURE:
%    Given an array of $N$ integers, find the maximum subarray sum.
%
%    \textbf{Input:} The first line contains $N$ ($1 \leq N \leq 10^5$).
%    The second line contains $N$ integers $a_i$ ($-10^9 \leq a_i \leq 10^9$).
%
%    \textbf{Output:} Print a single integer — the maximum subarray sum.
%
%    \textbf{Constraints:}
%    \begin{itemize}[noitemsep]
%      \item $1 \leq N \leq 10^5$
%      \item $-10^9 \leq a_i \leq 10^9$
%    \end{itemize}
% ════════════════════════════════════════════════════════════════════════════
\section*{Problem Statement}

Write your problem statement here.

\vspace{1em}

% ════════════════════════════════════════════════════════════════════════════
%  EXAMPLES
%  Fill in the test case tables below.
%  HOW TO FILL:
%    - Replace REPLACE\_WITH\_INPUT  with your actual input lines
%    - Replace REPLACE\_WITH\_OUTPUT with your actual output lines
%    - End EVERY line with \\ (two backslashes) for a line break
%    - Multiple lines example:
%        5 \\
%        1 2 3 4 5 \\
%    ⚠️  Do NOT delete \hline, \end{tabular}, or \end{minipage}
% ════════════════════════════════════════════════════════════════════════════
\section*{Examples}

LATEX

    # ── Append the generated test case tables ────────────────────────────────
    cat "$testcase_temp" >> "$tex_file"
    rm -f "$testcase_temp"

    # ── Append the closing sections ──────────────────────────────────────────
    cat >> "$tex_file" << 'LATEX'

% ════════════════════════════════════════════════════════════════════════════
%  EXPLANATION  (optional)
%  Explain why the output is correct for each example.
%  e.g: \textbf{Example 1:} The subarray [1,2,3,4,5] has sum 15.
% ════════════════════════════════════════════════════════════════════════════
\section*{Explanation (Optional)}

Explain the examples here, or delete this entire section if not needed.

% Uncomment below to add a warning/hint box:
% \begin{note}
% \textbf{Note:} Watch out for integer overflow when N is large.
% \end{note}

\end{document}
LATEX

    # ── Editor selection ─────────────────────────────────────────────────────
    echo
    echo "╔══════════════════════════════════════╗"
    echo "║   📝 Choose your editor              ║"
    echo "╠══════════════════════════════════════╣"
    echo "║  1) Vim                              ║"
    echo "║  2) Nano                             ║"
    echo "║  3) VS Code                          ║"
    echo "╚══════════════════════════════════════╝"
    echo
    read -p "👉 Enter choice (1/2/3): " editor_choice

    # Helper: open editor by name
    open_editor() {
        local editor_cmd="$1"
        case "$editor_cmd" in
            vim)
                echo "💡 Tip: Press 'i' to insert, fill in the sections, then 'Esc' → ':wq' to save & quit."
                sleep 2
                vim "$tex_file"
                ;;
            nano)
                echo "💡 Tip: Fill in the sections, then Ctrl+O to save, Ctrl+X to quit."
                sleep 2
                nano "$tex_file"
                ;;
            code)
                echo "💡 Tip: Fill in the sections, save with Ctrl+S, then CLOSE THE FILE TAB to continue."
                sleep 2
                code --wait "$tex_file"
                if [ $? -ne 0 ]; then
                    echo "⚠️  VS Code exited with an error or --wait not supported."
                    read -p "   Did you finish editing and save? (y/n): " vsc_confirm
                    if [ "$vsc_confirm" != "y" ]; then
                        echo "❌ Aborting."
                        rm -f "$tex_file"
                        sleep 1
                        ./problem_setter/ps_dashboard_main.sh "$username"
                        exit 1
                    fi
                fi
                ;;
        esac
    }

    # Helper: install a package
    install_pkg() {
        local pkg="$1"
        echo "⚠️  $pkg is not installed. Attempting to install..."
        sudo apt install -y "$pkg" 2>/dev/null || \
        sudo dnf install -y "$pkg" 2>/dev/null || \
        sudo pacman -Sy --noconfirm "$pkg" 2>/dev/null || \
        { echo "❌ Could not auto-install $pkg. Please install it manually."; return 1; }
    }

    case "$editor_choice" in
        1)
            if ! command -v vim &>/dev/null; then
                install_pkg vim || {
                    sleep 2
                    ./problem_setter/ps_dashboard_main.sh "$username"
                    exit 1
                }
            fi
            open_editor vim
            ;;
        2)
            if ! command -v nano &>/dev/null; then
                install_pkg nano || {
                    sleep 2
                    ./problem_setter/ps_dashboard_main.sh "$username"
                    exit 1
                }
            fi
            open_editor nano
            ;;
        3)
            if ! command -v code &>/dev/null; then
                echo "❌ VS Code is not installed or not in PATH."
                echo "   Install from: https://code.visualstudio.com"
                echo
                echo "   Falling back to another editor:"
                echo "   1) Vim   2) Nano"
                read -p "👉 Choice (1/2): " fallback_choice
                case "$fallback_choice" in
                    1)
                        if ! command -v vim &>/dev/null; then install_pkg vim; fi
                        open_editor vim
                        ;;
                    2)
                        if ! command -v nano &>/dev/null; then install_pkg nano; fi
                        open_editor nano
                        ;;
                    *)
                        echo "❌ Invalid. Aborting."
                        rm -f "$tex_file"
                        sleep 2
                        ./problem_setter/ps_dashboard_main.sh "$username"
                        exit 1
                        ;;
                esac
            else
                open_editor code
            fi
            ;;
        *)
            echo "❌ Invalid editor choice. Aborting."
            rm -f "$tex_file"
            sleep 2
            ./problem_setter/ps_dashboard_main.sh "$username"
            exit 1
            ;;
    esac

    # ── Validate file ─────────────────────────────────────────────────────────
    if [ ! -s "$tex_file" ]; then
        echo "❌ File is empty. Aborting."
        rm -f "$tex_file"
        sleep 2
        ./problem_setter/ps_dashboard_main.sh "$username"
        exit 1
    fi

    if ! grep -q "\\\\begin{document}" "$tex_file"; then
        echo "❌ File is malformed — \\begin{document} is missing."
        echo "   File kept at: $tex_file — fix manually and recompile."
        sleep 3
        ./problem_setter/ps_dashboard_main.sh "$username"
        exit 1
    fi

    # ── Compile ───────────────────────────────────────────────────────────────
    echo
    echo " 🔨 Compiling LaTeX to PDF..."

    compile_log=$(latexmk -pdf -interaction=nonstopmode \
        -output-directory="$pdf_dir" "$tex_file" 2>&1)
    compile_exit=$?

    if [ $compile_exit -eq 0 ]; then
        echo " ✅ PDF compiled → $pdf_dir/${username}_${safe_title}.pdf"
    else
        echo " ⚠️  Compilation failed. Errors found:"
        echo
        echo "$compile_log" | grep -E "^!|LaTeX Error|Undefined control|Emergency stop" | head -20
        echo
        echo "   1) Re-open editor to fix"
        echo "   2) Abort"
        read -p "👉 Choice (1/2): " fix_choice
        if [ "$fix_choice" = "1" ]; then
            case "$editor_choice" in
                1) open_editor vim ;;
                2) open_editor nano ;;
                3) open_editor code ;;
            esac
            echo " 🔨 Recompiling..."
            if latexmk -pdf -interaction=nonstopmode \
                -output-directory="$pdf_dir" "$tex_file" > /dev/null 2>&1; then
                echo " ✅ PDF compiled → $pdf_dir/${username}_${safe_title}.pdf"
            else
                echo " ❌ Failed again. File kept at: $tex_file"
                echo "    Problem will NOT be saved. Fix manually and resubmit."
                latexmk -c -output-directory="$pdf_dir" "$tex_file" > /dev/null 2>&1
                sleep 3
                ./problem_setter/ps_dashboard_main.sh "$username"
                exit 1
            fi
        else
            echo "❌ Aborted. File kept at: $tex_file"
            latexmk -c -output-directory="$pdf_dir" "$tex_file" > /dev/null 2>&1
            sleep 2
            ./problem_setter/ps_dashboard_main.sh "$username"
            exit 1
        fi
    fi

    # ── Extract test cases from compiled .tex into .txt files ─────────────────
    # Parse each tabular block from the tex file and save input/output separately
    for((i=1; i<=num_cases; i++)); do
        tc_file="${tc_dir}/${username}_${safe_title}_testcase${i}.txt"

        # Extract content between the i-th pair of minipage blocks
        # Input is first minipage, output is second minipage of each tabular
        tc_input=$(awk "
            /\\\\noindent\\\\textbf{Example $i}/ { found=1 }
            found && /TYPE YOUR INPUT BELOW/ { next }
            found && /\\\\begin{minipage}\[t\]/ { mp++; next }
            found && mp==1 && /\\\\end{minipage}/ { mp=0; found=0 }
            found && mp==1 { gsub(/ \\\\\\\\$/, \"\"); print }
        " "$tex_file")

        tc_output=$(awk "
            /\\\\noindent\\\\textbf{Example $i}/ { found=1 }
            found && /TYPE YOUR OUTPUT BELOW/ { next }
            found && /\\\\begin{minipage}\[t\]/ { mp++ }
            found && mp==2 && /\\\\end{minipage}/ { exit }
            found && mp==2 && !/\\\\begin{minipage}/ { gsub(/ \\\\\\\\$/, \"\"); print }
        " "$tex_file")

        printf "INPUT\n%s\n---OUTPUT---\n%s\n" "$tc_input" "$tc_output" > "$tc_file"
    done

    # Clean up aux files
    latexmk -c -output-directory="$pdf_dir" "$tex_file" > /dev/null 2>&1

    echo "${username}_${safe_title}|$problem_difficulty|$tags|$num_cases" >> database/problems.txt
    echo
    echo "✅ Problem '${problem_title}' created successfully!"
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
    echo "📄 Problem : $problem_name"
    echo "⚡ Difficulty : $(echo "$content" | cut -d'|' -f2)"
    echo "🏷️  Tags      : $(echo "$content" | cut -d'|' -f3)"
    echo "─────────────────────────────────"

    pdf_path="./database/problem_pdfs/${problem_name}.pdf"
    if [ -f "$pdf_path" ]; then
        echo "📑 PDF available at: $pdf_path"
    else
        echo "⚠️  No PDF found."
    fi

    echo
    read -p "Would you like to view the test cases? (y/n): " view_cases
    if [ "$view_cases" = "y" ]; then
        num_cases=$(echo "$content" | cut -d '|' -f 4)
        for((i=1; i<=num_cases; i++)); do
            tc_file="./database/test_case/${problem_name}_testcase${i}.txt"
            if [ -f "$tc_file" ]; then
                echo "─── Test Case $i ───────────────────"
                echo "📥 Input:"
                awk '/^INPUT$/{flag=1; next} /^---OUTPUT---$/{flag=0} flag' "$tc_file"
                echo "📤 Output:"
                awk '/^---OUTPUT---$/{flag=1; next} flag' "$tc_file"
                echo
            else
                echo "⚠️  Test case $i file not found."
            fi
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