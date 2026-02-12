#!/usr/bin/env ruby

# This script fixes the build phase order in the Xcode project to resolve the circular dependency
# It requires the xcodeproj gem: gem install xcodeproj

require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Runner target
runner_target = project.targets.find { |t| t.name == 'Runner' }

if runner_target.nil?
  puts "❌ Error: Could not find Runner target"
  exit 1
end

puts "✅ Found Runner target"

# Find the build phases
embed_extensions_phase = runner_target.copy_files_build_phases.find do |phase|
  phase.name == 'Embed Foundation Extensions' || phase.dst_subfolder_spec == '13'
end

if embed_extensions_phase.nil?
  puts "❌ Error: Could not find Embed Foundation Extensions phase"
  exit 1
end

puts "✅ Found Embed Foundation Extensions phase"

# Remove it from current position
runner_target.build_phases.delete(embed_extensions_phase)
puts "✅ Removed phase from current position"

# Find the index of the last script phase (Thin Binary should be last)
last_script_index = runner_target.build_phases.rindex { |phase| phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) }

if last_script_index.nil?
  # If no script phases found, add at the end
  runner_target.build_phases << embed_extensions_phase
  puts "✅ Added phase at the end (no script phases found)"
else
  # Insert after the last script phase
  runner_target.build_phases.insert(last_script_index + 1, embed_extensions_phase)
  puts "✅ Moved Embed Foundation Extensions after script phases"
end

# Save the project
project.save
puts "✅ Project saved successfully!"
puts ""
puts "Build phase order fixed! You can now build in Xcode."
