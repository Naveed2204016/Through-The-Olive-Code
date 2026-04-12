#!/bin/bash

# Check if latexmk is installed
if ! command -v latexmk &> /dev/null
then
    echo "latexmk not found. Installing..."

    # Detect package manager
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y latexmk
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y latexmk
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm latexmk
    else
        echo "Unsupported package manager. Please install latexmk manually."
        exit 1
    fi
fi

echo "latexmk is ready."
