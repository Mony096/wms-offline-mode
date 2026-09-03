import os
import re

path = "lib/feature/counting/quick_count/presentation/cubit/cycle_count_offline_cubit.dart"
with open(path, "r") as f:
    content = f.read()

lines = content.split('\n')
new_lines = []
in_post_method = False
for i, line in enumerate(lines):
    if re.match(r'^\s*Future<void>\s+post\(', line):
        in_post_method = True
        if "progressNotifier" not in line:
            line = line.replace(")", ", {ValueNotifier<String>? progressNotifier})")
    
    if in_post_method:
        if re.match(r'^\s*for\s*\(\s*var\s+item\s+in\s+items\s*\)\s*\{', line):
            indent = " " * (len(line) - len(line.lstrip()))
            new_lines.append(indent + "int _syncIndex = 0;")
            new_lines.append(line)
            new_lines.append(indent + "  _syncIndex++;")
            new_lines.append(indent + "  if (progressNotifier != null) progressNotifier.value = \"Syncing record $_syncIndex of ${items.length}...\";")
            continue
    
    new_lines.append(line)

with open(path, "w") as f:
    f.write("\n".join(new_lines))

print(f"Patched {path}")
