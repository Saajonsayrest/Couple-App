#!/bin/bash

# This script attempts to fix the Xcode build phase order using Python
# It will install pbxproj if needed

set -e

echo "🔧 Fixing Xcode build phase order..."

# Check if pip3 is available
if ! command -v pip3 &> /dev/null; then
    echo "❌ Error: pip3 not found. Please install Python 3 first."
    exit 1
fi

# Install pbxproj library
echo "📦 Installing pbxproj library..."
pip3 install --user pbxproj 2>/dev/null || python3 -m pip install --user pbxproj

# Create Python script
cat > /tmp/fix_build_phases.py << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
import sys
from pbxproj import XcodeProject

project_path = 'ios/Runner.xcodeproj/project.pbxproj'

try:
    project = XcodeProject.load(project_path)
    
    # Get the Runner target
    target = project.get_target_by_name('Runner')
    
    if not target:
        print("❌ Error: Could not find Runner target")
        sys.exit(1)
    
    print("✅ Found Runner target")
    
    # Get build phases
    build_phases = target.get('buildPhases', [])
    
    # Find the Embed Foundation Extensions phase
    embed_phase = None
    embed_index = None
    
    for i, phase_id in enumerate(build_phases):
        phase = project.objects[phase_id]
        if phase.get('name') == 'Embed Foundation Extensions' or phase.get('isa') == 'PBXCopyFilesBuildPhase':
            if phase.get('dstSubfolderSpec') == '13':  # PlugIns folder
                embed_phase = phase_id
                embed_index = i
                break
    
    if not embed_phase:
        print("❌ Error: Could not find Embed Foundation Extensions phase")
        sys.exit(1)
    
    print("✅ Found Embed Foundation Extensions phase at index", embed_index)
    
    # Find the last shell script phase index
    last_script_index = None
    for i, phase_id in enumerate(build_phases):
        phase = project.objects[phase_id]
        if phase.get('isa') == 'PBXShellScriptBuildPhase':
            last_script_index = i
    
    if last_script_index is None:
        print("⚠️  Warning: No script phases found, keeping current order")
    elif embed_index < last_script_index:
        # Remove from current position
        build_phases.pop(embed_index)
        # Insert after last script phase
        build_phases.insert(last_script_index, embed_phase)
        print(f"✅ Moved Embed Foundation Extensions from index {embed_index} to {last_script_index}")
        
        # Save the project
        project.save()
        print("✅ Project saved successfully!")
    else:
        print("✅ Build phases already in correct order!")
    
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)

PYTHON_SCRIPT

# Run the Python script
python3 /tmp/fix_build_phases.py

# Clean up
rm /tmp/fix_build_phases.py

echo ""
echo "✅ Done! You can now build in Xcode."
