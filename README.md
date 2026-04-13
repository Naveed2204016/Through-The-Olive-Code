# 🫒 Through The Olive Code 🫒
Terminal-Based Contest Management Platform

## 📋 Table of Contents
- [Overview](#overview)
- [⭐ New Features](#-new-features)
- [🚀 Getting Started](#-getting-started)
- [🎯 Features](#-features)
- [📁 Project Structure](#-project-structure)
- [🔐 User Roles](#-user-roles--access)
- [📝 Guidelines](#-guidelines)
- [🛠️ Troubleshooting](#-troubleshooting)

---

## Overview
A comprehensive Bash-based contest management system with support for multiple roles: Admin, Problem Setter, and Contestant. Now with **Virtual Contests**, **Contest Time Updates**, and **Anonymous Participation**!

---

## ⭐ NEW FEATURES

### 🔵 Virtual Contests
Contests that are always available for participation - perfect for practice rounds and makeup contests.
- **Access:** Anytime, no time limits
- **Pre-registration:** Not required
- **Use Case:** Practice rounds, makeup contests

### ⏰ Contest Time Updates  
Admins can now update contest timing after creation without losing any data.
- **Update Date & Time:** Modify scheduled contests on-the-fly
- **No Cancellation:** Keep all existing data and registrations
- **Immediate Effect:** Changes apply instantly

### 🕵️ Anonymous Contest Attendance
Participate in contests without revealing your identity.
- **Format:** `@anonymous_XXXXXX` (unique code)
- **No Login:** Anonymous participation requires no account
- **Privacy:** Identity completely hidden
- **Statistics:** Tracked anonymously on leaderboards

**👉 See [FEATURES.md](FEATURES.md) for detailed documentation on all new features.**

---

## 🚀 Getting Started

### Prerequisites
- **Windows Users**: Git Bash or WSL (Windows Subsystem for Linux) installed
- **Linux/Mac Users**: Bash shell (pre-installed)

### Installation & Running

#### Option 1: Windows Users (Easiest)
1. Navigate to the project directory
2. **Double-click `run.bat`** to launch the application

#### Option 2: PowerShell (Windows)
```powershell
cd C:\Users\syeds\desktop\shell\Through-The-Olive-Code
.\run.ps1
```

#### Option 3: Linux/Mac or WSL
```bash
cd ~/path-to/Through-The-Olive-Code
./main.sh
```

### First-Time Setup
```bash
# If updating from previous version, run migration once:
bash database_migration.sh
```

---

## 🎯 Features

### 👑 Admin Dashboard
- **Create Contests:** Both live and virtual contests
- **Manage Users:** Contestants and problem setters
- **Update Contest Times:** Modify dates/times without recreating
- **Contest Management:** Full lifecycle management
- **View All Contests:** See all live and virtual contests

### 🧠 Problem Setter Dashboard
- Create and submit problem statements
- Set test cases for problems
- Manage problem metadata

### ⚔️ Contestant Dashboard
- Register for contests
- View and attempt problems
- Submit solutions
- Track leaderboard standings
- **Join virtual contests anytime**
- **Participate anonymously**

### 👥 Anonymous Mode
- Join contests without login
- Automatic anonymous identity generation
- All statistics recorded anonymously

---

## 📁 Project Structure
```
Through-The-Olive-Code/
├── main.sh                    # Main entry point
├── run.bat                    # Windows batch launcher
├── run.ps1                    # PowerShell launcher
├── utils.sh                   # Utility functions
├── database_migration.sh       # Database migration tool
├── README.md                  # This file
├── FEATURES.md                # Detailed feature documentation
├── admin/
│   ├── admin_dashboard.sh
│   ├── admin_dashboard_main.sh
│   ├── admin_login.sh
│   ├── admin_signup.sh
│   └── contest_management.sh  # NEW: Contest management
├── problem_setter/
│   ├── ps_dashboard_main.sh
│   ├── ps_dashboard.sh
│   ├── ps_login.sh
│   └── ps_signup.sh
├── contestant/
│   ├── contestant_dashboard.sh
│   ├── contestant_dashboard_main.sh
│   ├── contestant_login.sh
│   ├── contestant_signup.sh
│   ├── contest_arena.sh       # UPDATED: Virtual & anonymous support
│   └── anonymous_login.sh     # NEW: Anonymous entry
└── database/
    ├── contest.txt            # UPDATED: 10 fields with virtual flag
    ├── contestant.txt
    ├── problem_setter.txt
    ├── admin.txt
    ├── problem_statement/
    ├── test_case/
    ├── submissions/
    ├── contest_submissions/
    ├── registration/
    └── final_leaderboard/
```

---

## 🔐 User Roles & Access

| Role | Features |
|------|----------|
| **Admin** | Full system access, user/contest management, **update contest times** |
| **Problem Setter** | Create problems, set test cases, manage metadata |
| **Contestant** | Register & compete, **join virtual contests, participate anonymously** |
| **Anonymous User** | Join any contest without login, complete privacy |

---

## 📝 Guidelines

### For Developers
1. Use `run.bat` or `run.ps1` for Windows compatibility
2. Follow role-based directory structure
3. Use `utils.sh` functions for common operations
4. Support both live and virtual contests in logic
5. Test thoroughly before committing
6. Update documentation when adding features

### For Admins
1. **First Update:** Run `bash database_migration.sh` if updating
2. **New Contests:** Choose between live (scheduled) or virtual (always available)
3. **Time Updates:** Use "Update Contest Time" instead of canceling
4. **Monitor:** View all contests with their types

### For Contestants
1. **Live Contests:** Pre-register to join at scheduled time
2. **Virtual Contests:** No registration needed, join anytime
3. **Anonymous:** Select "Anonymous Contest" for privacy
4. **Statistics:** Data tracked with your username (real or anonymous)

### For Contributors
1. Create branch: `git checkout -b feature-name`
2. Test all changes
3. Update README.md and FEATURES.md
4. Test with both live and virtual contests
5. Create Pull Request

### Database Management
- Credentials stored with SHA256 hashing
- All submissions logged
- Leaderboards auto-updated
- **NEW:** Contest file includes virtual flag (field 10)
- **NEW:** Anonymous usernames are generated from system time

---

## 🛠️ Troubleshooting

### "Command not found" Error
- **Windows**: Install Git Bash or WSL
- **Solution**: Use `run.bat` or `run.ps1` instead of `./main.sh`

### Permission Denied
```bash
# Linux/Mac - make scripts executable
chmod +x *.sh admin/*.sh problem_setter/*.sh contestant/*.sh
```

### Database Access Issues
- Check files exist in `/database` directory
- Verify read/write permissions
- Ensure sufficient disk space

### Virtual Contest Not Showing
- Verify `database_migration.sh` was run
- Check contest.txt has 10 fields
- Ensure `is_virtual=1` flag is set

### Anonymous Username Not Generating
- Verify `utils.sh` is in project root
- Check system time is correct
- Ensure bash supports nanosecond timestamps

---

## 📊 Database Format

### Contest File (database/contest.txt)
```
name|division|applicants|ps|test_probs|final_probs|date|start|end|is_virtual
```

**Field 10:** `is_virtual`
- `0` = Live contest (requires pre-registration)
- `1` = Virtual contest (always available)

### Example Entries
```
Round1|2|...|...|...|...|2026-03-07|08:00|09:00|0
Practice|1|...|...|...|...|VIRTUAL|00:00|23:59|1
```

---

## 🚀 Quick Commands

### Run Application
```bash
# Windows
./run.bat
.\run.ps1

# Linux/Mac/WSL
./main.sh
```

### Database Maintenance
```bash
# First-time migration (updating from v1.x)
bash database_migration.sh

# Make scripts executable (Linux/Mac)
chmod +x *.sh admin/*.sh problem_setter/*.sh contestant/*.sh
```

---

## 📚 Documentation

- **[FEATURES.md](FEATURES.md)** - Detailed documentation of all new features
- **[main.sh](main.sh)** - Main application entry point
- **[utils.sh](utils.sh)** - Shared utility functions

---

## 🤝 Support
For issues or questions, contact the development team or open an issue in the repository.

---

## 📄 License
This project is part of the IUPC Contest Management System.

---

**Last Updated:** April 13, 2026  
**Version:** 2.0 (Virtual Contests & Anonymous Access)  
**Status:** Production Ready ✅

### What's New in v2.0:
- ✅ Virtual Contests (always-available practice contests)
- ✅ Contest Time Updates (modify dates/times after creation)
- ✅ Anonymous Contest Attendance (hidden identity participation)
- ✅ Utility Functions Module (shared utilities for scripts)
- ✅ Database Migration Tool (seamless upgrade from v1.x)
- ✅ Enhanced Documentation (FEATURES.md guide)
# 🫒 Through The Olive Code 🫒
Terminal-Based Contest Management Platform

## Overview
A comprehensive Bash-based contest management system with support for multiple roles: Admin, Problem Setter, and Contestant.

---

## 🚀 Getting Started

### Prerequisites
- **Windows Users**: Git Bash or WSL (Windows Subsystem for Linux) installed
- **Linux/Mac Users**: Bash shell (pre-installed)

### Installation & Running

#### Option 1: Windows Users (Easiest)
1. Navigate to the project directory
2. **Double-click `run.bat`** to launch the application
   - This will automatically use Git Bash to run the project

#### Option 2: PowerShell (Windows)
```powershell
cd C:\Users\syeds\desktop\shell\Through-The-Olive-Code
.\run.ps1
```

#### Option 3: Linux/Mac or WSL
```bash
cd ~/path-to/Through-The-Olive-Code
./main.sh
```

---

## 📋 Features

### 👑 Admin Dashboard
- Manage users and contests
- Create and oversee rounds
- Access admin panel with authentication

### 🧠 Problem Setter Dashboard
- Create and submit problem statements
- Set test cases for problems
- Manage problem metadata

### ⚔️ Contestant Dashboard
- Register for contests
- View and attempt problems
- Submit solutions
- Track leaderboard standings

---

## 📁 Project Structure
```
Through-The-Olive-Code/
├── main.sh                 # Main entry point
├── run.bat                 # Windows batch launcher
├── run.ps1                 # PowerShell launcher
├── admin/                  # Admin panel scripts
├── problem_setter/         # Problem setter scripts
├── contestant/             # Contestant scripts
└── database/               # Data storage and submissions
    ├── users data files
    ├── problem statements
    ├── test cases
    ├── submissions
    └── leaderboards
```

---

## 🔐 User Roles & Access

| Role | Access | Features |
|------|--------|----------|
| **Admin** | Full system access | User management, contest setup, system logs |
| **Problem Setter** | Problem creation | Create problems, set test cases, upload statements |
| **Contestant** | Contest participation | Register, submit solutions, view leaderboard |

---

## 📝 Guidelines

### For Developers
1. Always test scripts in a fresh terminal session
2. Use the provided launcher scripts (`run.bat` or `run.ps1`) for Windows compatibility
3. Follow the role-based directory structure when adding features
4. Update database files in the `database/` directory only through scripts
5. Maintain backward compatibility with existing user data

### For Contributors
1. Create a new branch for features: `git checkout -b feature-name`
2. Test all changes before committing
3. Write clear commit messages describing changes
4. Update README.md if adding new features or roles
5. Push changes and create a Pull Request

### Database Management
- User credentials are stored with SHA256 hashing
- All submissions are logged in the database
- Leaderboards are automatically updated after each submission
- Backup database files before major updates

---

## 🛠️ Troubleshooting

### "Command not found" Error
- **Windows**: Make sure Git Bash or WSL is installed
- **Solution**: Use `run.bat` or `run.ps1` instead of `./main.sh`

### Permission Denied
- Run with appropriate permissions
- On Linux/Mac: `chmod +x *.sh admin/*.sh problem_setter/*.sh contestant/*.sh`

### Database Access Issues
- Ensure database files exist in `/database` directory
- Check file permissions and disk space
- Verify the application has read/write access

---

## 🤝 Support
For issues or questions, please contact the development team or open an issue in the repository.

---

## 📄 License
This project is part of the IUPC Contest Management System.

---

**Last Updated**: April 13, 2026
**Version**: 1.0
