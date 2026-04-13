#!/bin/bash

# ============================================
# DATABASE MIGRATION SCRIPT
# Migrates existing contests to new format with virtual contest support
# ============================================

echo "🔄 Starting Database Migration..."
echo "==============================================="

contest_file="./database/contest.txt"

if [ ! -f "$contest_file" ]; then
    echo "⚠️  Contest file not found. Skipping migration."
    exit 0
fi

# Backup current contest file
backup_file="${contest_file}.backup.$(date +%s)"
cp "$contest_file" "$backup_file"
echo "✅ Backup created: $backup_file"

# Check if migration already done (10 fields instead of 9)
first_line=$(head -n 1 "$contest_file")
field_count=$(echo "$first_line" | awk -F'|' '{print NF}')

if [ "$field_count" -eq 10 ]; then
    echo "✅ Database already migrated (10 fields detected)."
    exit 0
elif [ "$field_count" -ne 9 ]; then
    echo "⚠️  Unexpected field count: $field_count"
    echo "   Expected: 9 (original) or 10 (migrated)"
    exit 1
fi

# Migrate each contest - add is_virtual=0 (all existing contests are live)
echo "📝 Migrating contests..."

awk -F'|' -v OFS='|' '{
    # Add is_virtual field (0 for live contests)
    print $0 "|0"
}' "$contest_file" > "${contest_file}.new"

# Replace original with migrated version
mv "${contest_file}.new" "$contest_file"

# Count migrated contests
migrated_count=$(wc -l < "$contest_file")
echo "✅ Migrated $migrated_count contests successfully"

echo ""
echo "📋 Migrated Contests:"
cat "$contest_file" | awk -F'|' '{printf "%s | %s | %s-%s (Live)\n", $1, $7, $8, $9}'

echo ""
echo "✅ Migration Complete!"
echo "   All existing contests marked as LIVE (is_virtual=0)"
echo "   You can now create VIRTUAL contests via admin panel"
