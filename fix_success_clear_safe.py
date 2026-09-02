import os

cubit_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('offline_cubit.dart') and 'failed' not in file:
            cubit_files.append(os.path.join(root, file))

patched = 0

for filepath in cubit_files:
    with open(filepath, 'r') as f:
        lines = f.readlines()

    original_lines = lines.copy()
    
    in_commented_block = False

    for i, line in enumerate(lines):
        # Determine if we are inside a commented out block of code
        # A good heuristic: if the line above is a comment and this line is successRecords.clear();
        # Actually, let's just look at whether the line before was `//   // // failedRecords.clear();`
        
        # If the line is exactly `  successRecords.clear();\n` or similar, we check the line above.
        if 'successRecords.clear();' in line:
            # Check the line above it
            if i > 0 and 'failedRecords.clear();' in lines[i-1]:
                # If the line above has `//`, then this line should ALSO have `//` if it's supposed to be commented.
                # BUT wait! In the active `post()`, the line above IS commented out!
                # `    // // failedRecords.clear();`
                # So how do we know if THIS block is commented out?
                # We check the line 5 lines above! `    // 1️⃣ Clear data before sync attempt`
                pass

        # A much more robust way: Find `void post(` or `Future<void> post(`.
        # If the line defining the method starts with `//`, the whole block is commented.
        if 'void post(' in line or 'Future<void> post(' in line:
            if line.strip().startswith('//'):
                in_commented_block = True
            else:
                in_commented_block = False
                
        if 'successRecords.clear();' in line:
            if in_commented_block:
                # Put the comment back!
                # Replace `successRecords.clear();` with `// successRecords.clear();`
                # Let's restore it to exactly what it probably was: `  //   // successRecords.clear();`
                lines[i] = line.replace('successRecords.clear();', '// successRecords.clear();')

    if lines != original_lines:
        with open(filepath, 'w') as f:
            f.writelines(lines)
        patched += 1
        print(f"Patched {filepath}")

print(f"Patched {patched} files.")

