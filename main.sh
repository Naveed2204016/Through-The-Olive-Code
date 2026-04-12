#!/bin/bash

clear
./all_execution_permission.sh
echo "============================================================"
echo "               🫒 THROUGH THE OLIVE CODE 🫒                 "
echo "        Terminal-Based Contest Management Platform           "
echo "============================================================"
echo
echo "                   🚀 CHOOSE YOUR ROLE 🚀                   "
echo
echo " ---------------------------------------------------------- "
echo " |  Press |        Role                                    |"
echo " ---------------------------------------------------------- "
echo " |   1    |  👑 Admin                                      |"
echo " |   2    |  🧠 Problem Setter                             |"
echo " |   3    |  ⚔️ Contestant                                 |"
echo " ---------------------------------------------------------- "
echo
echo -n "👉 Enter your choice (1/2/3): "
read choice

case $choice in
  1)
    clear
    echo "👑 Redirecting to Admin Panel..."
    sleep 1
    ./admin/admin_dashboard.sh
    ;;
  2)
    clear
    echo "🧠 Redirecting to Problem Setter Panel..."
    sleep 1
    ./problem_setter/ps_dashboard.sh
    ;;
  3)
    clear
    echo "⚔️ Redirecting to Contestant Panel..."
    sleep 1
    ./contestant/contestant_dashboard.sh
    ;;
  *)
    echo "❌ Invalid choice! Please enter 1, 2, or 3."
    sleep 2
    ./main.sh
    ;;
esac
