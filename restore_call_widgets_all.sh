#!/bin/bash

echo "🔄 Restoring all call widgets to original state..."

# Check if backup directory exists
if [ ! -d "backup_call_widgets_all" ]; then
    echo "❌ Backup directory not found!"
    echo "Please run the apply script first to create backups."
    exit 1
fi

# Restore all widget files
echo "📁 Restoring widget files..."
cp -r backup_call_widgets_all/* lib/features/call/presentation/widget/

echo "✅ All call widgets have been restored to their original state!"
echo "🎯 Restored files:"
echo "   - hospital_card.dart"
echo "   - food_product_card.dart"
echo "   - community_card.dart"
echo "   - beauty_command_card.dart"
echo "   - fashion_command_card.dart"
echo "   - foods_command_card.dart"
echo "   - care_command_card.dart"
echo "   - event_card.dart"

echo ""
echo "🚀 You can now run 'flutter run' to test the restored widgets." 