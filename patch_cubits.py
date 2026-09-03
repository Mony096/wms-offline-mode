import os
import re

directory = "lib/feature"

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith("_offline_cubit.dart") and "failed" not in file.lower() and "barcode" not in file.lower() and "request" not in file.lower() and "cycle_count" not in file.lower():
            path = os.path.join(root, file)
            with open(path, "r") as f:
                content = f.read()

            # Find the active post method (not commented out)
            # ^\s*Future<void> post\(
            
            lines = content.split('\n')
            new_lines = []
            in_post_method = False
            for i, line in enumerate(lines):
                # Update signature
                if re.match(r'^\s*Future<void>\s+post\(', line):
                    in_post_method = True
                    # if it doesn't already have progressNotifier, add it
                    if "progressNotifier" not in line:
                        # find the closing parenthesis of the parameters
                        if ")" in line:
                            # if it's empty args
                            if "()" in line:
                                line = line.replace("()", "({ValueNotifier<String>? progressNotifier})")
                            else:
                                line = line.replace(")", ", {ValueNotifier<String>? progressNotifier})")
                
                # If we are inside the post method, look for the loop
                if in_post_method:
                    if re.match(r'^\s*for\s*\(\s*var\s+item\s+in\s+items\s*\)\s*\{', line):
                        # Inject index tracker and progress update
                        indent = " " * (len(line) - len(line.lstrip()))
                        new_lines.append(indent + "int _syncIndex = 0;")
                        new_lines.append(line)
                        new_lines.append(indent + "  _syncIndex++;")
                        new_lines.append(indent + "  if (progressNotifier != null) progressNotifier.value = \"Syncing record $_syncIndex of ${items.length}...\";")
                        continue
                
                new_lines.append(line)
                
            new_content = "\n".join(new_lines)
            
            if new_content != content:
                with open(path, "w") as f:
                    f.write(new_content)
                print(f"Patched {path}")

