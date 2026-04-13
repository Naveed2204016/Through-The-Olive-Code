#!/bin/bash

# ============================================
# UTILITY FUNCTIONS FOR CONTEST MANAGEMENT
# ============================================

# Generate anonymous username based on current time
generate_anonymous_username() {
    # Create a mathematical function-based code from current system time
    timestamp=$(date +%s%N)  # Get nanosecond precision timestamp
    
    # Mathematical operations: (timestamp * prime) mod large_number
    prime_num=31
    modulo=999999
    
    anon_code=$(( (${timestamp:0:10} * prime_num) % modulo ))
    
    # Ensure at least 5 digits
    anon_code=$(printf "%06d" "$anon_code")
    
    echo "@anonymous_${anon_code}"
}

# Check if a contest is still available (not ended)
is_contest_available() {
    local contest_name="$1"
    local contest_file="./database/contest.txt"
    
    if [ ! -f "$contest_file" ]; then
        echo "0"
        return
    fi
    
    # Get contest info
    contest_line=$(grep "^$contest_name|" "$contest_file")
    
    if [ -z "$contest_line" ]; then
        echo "0"
        return
    fi
    
    # Extract fields
    IFS='|' read -r name division applicants_file ps_file t_problems f_problems contest_date start_time end_time is_virtual < <(echo "$contest_line")
    
    current_date=$(date +%Y-%m-%d)
    current_time=$(date +%H:%M)
    
    # If virtual contest, it's always available
    if [ "$is_virtual" = "1" ]; then
        echo "1"
        return
    fi
    
    # For live contests, check date and time
    if [ "$contest_date" = "$current_date" ]; then
        if [[ ("$current_time" > "$start_time" || "$current_time" = "$start_time") && \
              ("$current_time" < "$end_time" || "$current_time" = "$end_time") ]]; then
            echo "1"
            return
        fi
    fi
    
    echo "0"
}

# Get contest details
get_contest_details() {
    local contest_name="$1"
    local contest_file="./database/contest.txt"
    
    if [ ! -f "$contest_file" ]; then
        echo ""
        return
    fi
    
    grep "^$contest_name|" "$contest_file"
}

# Check if username exists (for checking real vs anonymous)
username_exists() {
    local username="$1"
    
    if [[ "$username" == @anonymous_* ]]; then
        return 1  # Anonymous users don't exist in contestant.txt
    fi
    
    if grep -q "^$username|" database/contestant.txt 2>/dev/null; then
        return 0  # Username exists
    fi
    
    return 1  # Username doesn't exist
}

# Register user for contest (handles anonymous users)
register_for_contest() {
    local username="$1"
    local contest_name="$2"
    local registration_file="./database/registration/${contest_name}.txt"
    
    if [ ! -f "$registration_file" ]; then
        touch "$registration_file"
    fi
    
    # Check if already registered
    if ! grep -q "^$username$" "$registration_file" 2>/dev/null; then
        echo "$username" >> "$registration_file"
    fi
}

export -f generate_anonymous_username
export -f is_contest_available
export -f get_contest_details
export -f username_exists
export -f register_for_contest
