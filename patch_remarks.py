import os
import re

directory = "lib/feature"

remark_block = """              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Remark",
                    style: TextStyle(
                      fontSize: 14.3,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: remark,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter remark...',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
"""

for root, _, files in os.walk(directory):
    for file in files:
        if file.startswith("create_") and file.endswith("_screen.dart"):
            path = os.path.join(root, file)
            # Skip the one we already manually did
            if "good_receipt/presentation/create_good_receipt_screen.dart" in path:
                continue

            with open(path, "r") as f:
                content = f.read()

            if "final remark = TextEditingController();" not in content and "final TextEditingController remark" not in content:
                # If there's no remark controller, skip
                if "remark" not in content.lower():
                    continue
            
            # Step 1: Remove or comment out the old Input
            # Regex to match: Input( \n label: 'Remark', \n placeholder: 'Remark', \n controller: remark, \n )
            pattern = r"Input\(\s*label:\s*'Remark',\s*placeholder:\s*'Remark',\s*controller:\s*remark,?\s*\),?"
            
            # Some files might have it formatted differently, let's use a more robust regex
            # or just look for lines containing "label: 'Remark'" and remove the Input block around it.
            # A safer way: replace by looking for the whole block
            
            def replace_old_input(m):
                # Return empty to remove it
                return ""
            
            # It might have a trailing comma
            content, count = re.subn(pattern, replace_old_input, content, flags=re.DOTALL)
            
            if count == 0:
                print(f"Old remark input not found in {path}, maybe already removed or different format?")
            
            # Step 2: Insert new remark block right before the Add Item button container.
            # The Add Item button container usually looks like:
            #               const SizedBox(height: 20),
            #               Container(
            #                 margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            #                 child: Button(
            
            # Or some variation. Let's find `onPressed: onAddItem,`
            # and trace backwards to the `Container` and `SizedBox`.
            
            # Let's search for the pattern that leads to the button
            # We want to match:
            # \s*const SizedBox\(height:\s*20\);\s*Container\([^)]*onPressed:\s*onAddItem,
            # wait, onAddItem is deeper inside Button.
            # Let's just match `const SizedBox(height: 20);\n              Container(\n` 
            # and replace it with `remark_block + const SizedBox...`
            # BUT we only want to do this ONCE near the Add Item button.
            
            # Since some files might have different heights (e.g. 20), we can look for:
            # \n              const SizedBox\(height: \d+\);\n              Container\(\n\s*margin: EdgeInsets.fromLTRB\(0, 0, 0, 20\),
            # OR we can just inject it right before `Button(` if it has `onPressed: onAddItem`.
            # Let's find the line with `onPressed: onAddItem`.
            
            lines = content.split('\n')
            button_line_idx = -1
            for i, line in enumerate(lines):
                if 'onPressed: onAddItem,' in line:
                    button_line_idx = i
                    break
            
            if button_line_idx != -1:
                # trace up to find the SizedBox
                insert_idx = button_line_idx
                while insert_idx > 0:
                    if 'const SizedBox(height: ' in lines[insert_idx] or 'Container(' in lines[insert_idx]:
                        # if we see a SizedBox followed by a Container, we can insert before the SizedBox
                        # Let's just trace up to the first SizedBox
                        if 'const SizedBox(height: ' in lines[insert_idx]:
                            break
                    insert_idx -= 1
                
                # Now insert
                lines.insert(insert_idx, remark_block)
                new_content = "\n".join(lines)
                
                with open(path, "w") as f:
                    f.write(new_content)
                print(f"Patched {path}")
            else:
                print(f"Could not find onAddItem in {path}")

