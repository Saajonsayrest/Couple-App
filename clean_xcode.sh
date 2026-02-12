#!/bin/bash

# Simple fix for the Xcode build cycle by cleaning derived data
echo "🧹 Cleaning Xcode derived data..."

# Close Xcode if it's running (optional, comment out if you want to keep it open)
# osascript -e 'quit app "Xcode"'

# Remove derived data for this project
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

echo "✅ Derived data cleaned!"
echo ""
echo "Now in Xcode:"
echo "1. Go to Product → Clean Build Folder (Shift+Cmd+K)"
echo "2. Try building again"
echo ""
echo "If the error persists, the widget might need to be set up differently."
echo "Consider using the widget only on Android for now."
