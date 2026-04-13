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
