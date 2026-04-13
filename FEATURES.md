# 🎯 NEW FEATURES DOCUMENTATION

## Overview
Three major features have been added to the contest management system:
1. **Virtual Contests** - Always-available contests for flexible participation
2. **Contest Time Updates** - Ability to update contest timing after creation
3. **Anonymous Contest Attendance** - Participate without revealing identity

---

## 1️⃣ VIRTUAL CONTESTS

### What is a Virtual Contest?
A virtual contest is a contest that is always available for participation, regardless of the date or time. This allows contestants who couldn't attend the live contest to participate later.

### How to Create a Virtual Contest (Admin)
1. Go to Admin Dashboard → "1. Create a New Contest"
2. Enter contest name and division
3. Select **Contest Type: 2️⃣  Virtual Contest**
4. The system will automatically set it as always available
5. All other settings (problem selection, etc.) work the same

### How to Join a Virtual Contest (Contestant)
1. Log in with your account
2. Go to "Contest Arena"
3. Virtual contests appear with **🔵 VIRTUAL** label
4. Select and join - **no pre-registration needed**
5. Compete at your own pace with no time limit

### Database Format
- Virtual contests have `is_virtual=1` in database
- Format: `contest_name|division|...|contest_date|start_time|end_time|is_virtual`
- Virtual contests use `VIRTUAL|00:00|23:59` for date/time fields

---

## 2️⃣ CONTEST TIME UPDATES

### What is Contest Time Update?
After creating a contest, admins can now modify the scheduled date and time without canceling the contest.

### How to Update Contest Time (Admin)
1. Go to Admin Dashboard → "6️⃣  Update Contest Time"
2. View all contests
3. Select the contest number to update
4. Enter new date and time
5. Changes take effect immediately

### Important Notes
- **Live contests**: Changes affect when the contest is available
- **Virtual contests**: Time updates don't affect availability (always accessible)
- Old date/time entries are replaced with new ones
- Contestant registrations remain intact

### Database Impact
The contest.txt file is updated with new date and time values without removing the contest entry.

---

## 3️⃣ ANONYMOUS CONTEST ATTENDANCE

### What is Anonymous Contest?
Participate in contests without revealing your identity. Your username is replaced with a unique code (`@anonymous_XXXXXX`).

### How to Join Anonymously (Contestant)
1. Go to Contestant Panel
2. Select **"3️⃣  Anonymous Contest (No Login Required)"**
3. A unique anonymous username is generated automatically
4. Select from available contests (both live and virtual)
5. Participate and submit solutions
6. Your statistics are recorded under the anonymous username

### Anonymous Username Generation
- Generated using mathematical functions based on system time
- Format: `@anonymous_XXXXXX` (where X = calculated digits)
- Example: `@anonymous_123456`
- Each session generates a unique anonymous ID

### Anonymous Contest Features
✅ **No Login Required**
✅ **Always Available for Virtual Contests**
✅ **Can Join Live Contests During Active Time**
✅ **Anonymous Statistics on Leaderboards**
✅ **Hidden Identity in Submissions**

### Advantages
- Privacy: Identity remains hidden
- Flexibility: No account creation needed
- Try Before Join: Test contests without commitment
- Practice: Multiple anonymous attempts

### Database Storage
- Stored as `@anonymous_XXXXXX` in all contest files
- Submission files use anonymous username
- Leaderboards show anonymous usernames only
- Cannot be traced back to real identity

---

## 📊 DATABASE FORMAT CHANGES

### Contest File Format (database/contest.txt)
**Old Format (9 fields):**
```
contest_name|division|applicants_file|ps_file|t_problems|f_problems|date|start_time|end_time
```

**New Format (10 fields):**
```
contest_name|division|applicants_file|ps_file|t_problems|f_problems|date|start_time|end_time|is_virtual
```

### Example Entries:
```
# Live Contest
Round1|2|Round1_applicants.txt|Round1_ps.txt|Round1_t_problems.txt|Round1_f_problems.txt|2026-03-07|08:00|09:00|0

# Virtual Contest
Practice|1|Practice_applicants.txt|Practice_ps.txt|Practice_t_problems.txt|Practice_f_problems.txt|VIRTUAL|00:00|23:59|1
```

### Registration File Format (database/registration/CONTEST_NAME.txt)
```
username1
username2
@anonymous_123456
@anonymous_789012
```

---

## 🛠️ UTILITY FUNCTIONS

Located in `utils.sh`, these functions are available for scripts:

### `generate_anonymous_username()`
Generates a unique anonymous username based on system time.

### `is_contest_available(contest_name)`
Returns 1 if contest can be joined, 0 otherwise.

### `get_contest_details(contest_name)`
Returns full contest details from database.

### `username_exists(username)`
Checks if username is a real user (not anonymous).

### `register_for_contest(username, contest_name)`
Registers a user for a contest.

---

## 📝 ADMIN MENU - UPDATED OPTIONS

```
1️⃣  Create a New Contest
    └─ ✨ Now supports Virtual Contest creation

2️⃣  Select Problem Setters
    └─ Works for both live and virtual contests

3️⃣  Select Problem Set
    └─ Works for both live and virtual contests

4️⃣  Manage Contestants
    └─ Perform management operations

5️⃣  Manage Problem Setters
    └─ Perform management operations

6️⃣  Update Contest Time ⭐ NEW
    └─ Modify contest date and time after creation

7️⃣  View All Contests ⭐ NEW
    └─ See all live and virtual contests

8️⃣  Cancel a Contest
    └─ Remove contest completely

9️⃣  Exit
    └─ Return to admin panel
```

---

## 👥 CONTESTANT MENU - UPDATED OPTIONS

```
1️⃣  Login
    └─ Log in with your account to join registered contests

2️⃣  Sign Up
    └─ Create a new account

3️⃣  Anonymous Contest ⭐ NEW
    └─ Join contests anonymously without login

4️⃣  Back to Landing Page
    └─ Return to main menu
```

---

## 🎯 USE CASES

### Scenario 1: Practice Contest
**Admin:** Creates a virtual contest "Practice Round"
**Contestants:** Can join anytime, practice at their own pace, no time limits

### Scenario 2: Live Contest with Reschedule
**Admin:** Creates live contest scheduled for 8 AM
**Admin:** Later decides to reschedule to 9 AM using "Update Contest Time"
**Contestants:** See the new time and can join during the new window

### Scenario 3: Anonymous Participation
**User:** Wants to try a contest without revealing identity
**User:** Selects "Anonymous Contest" → joins automatically with hidden username
**User:** Participates and sees results under anonymous name

### Scenario 4: Flexible Contest Format
**Admin:** Creates virtual contest for contest that couldn't happen live
**Contestants:** Some competed during virtual mode, some compete later
**Admin:** Can view all submissions on leaderboard regardless of when they joined

---

## ⚡ IMPORTANT NOTES

1. **Pre-registration for Live Contests**
   - Live contests still require pre-registration
   - Virtual contests allow any user to join directly

2. **Virtual Contest Default Times**
   - Always set to `VIRTUAL|00:00|23:59`
   - Changing these values doesn't limit access

3. **Anonymous Username Uniqueness**
   - Each session generates a unique code
   - Based on nanosecond precision timestamps
   - Collision rate is extremely low

4. **Leaderboard Display**
   - Shows real usernames for registered contestants
   - Shows anonymous usernames for anonymous participants
   - Mixed leaderboards are possible

5. **Statistics Tracking**
   - Anonymous stats are tracked separately
   - Cannot be merged with real accounts
   - Submissions remain anonymous

---

## 🔄 WORKFLOW EXAMPLES

### Creating and Running a Virtual Contest
```
Admin: Create Virtual Contest → Interactive setup
↓
Admin: Select Problem Setters → Choose setters
↓
Admin: Select Problem Set → Finalize problems
↓
Contestants: Can join anytime → Participate anonymously or with account
↓
Results: Tracked with all submissions
```

### Updating a Live Contest Time
```
Admin: Create Live Contest (8 AM scheduled)
↓
Issue: Need to reschedule
↓
Admin: Update Contest Time → New time 9 AM
↓
Contestants: See updated time
↓
Contest: Runs at new scheduled time
```

---

## 📞 SUPPORT & TROUBLESHOOTING

**Q: Can I change a live contest to virtual?**
A: Yes, recreate the contest with virtual option or manually update database.

**Q: How is anonymous data secured?**
A: Stored with system-time-based codes that don't trace back to real identity.

**Q: Can admins see who participated anonymously?**
A: No - the system is designed to hide identity completely.

**Q: What if anonymous contest timer conflicts?**
A: Virtual contests have no timer; anonymous users on live contests have normal timer.

---

**Last Updated:** April 13, 2026
**Version:** 1.0
**Status:** Production Ready ✅
