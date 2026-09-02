import os
import re

cubit_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('offline_cubit.dart') and 'failed' not in file:
            cubit_files.append(os.path.join(root, file))

patched = 0

for filepath in cubit_files:
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Replace commented out successRecords.clear(); with actual successRecords.clear();
    # We want to do this only in the active post() method, but doing it globally is safe since it's just uncommenting.
    content = re.sub(r'//\s*//\s*successRecords\.clear\(\);', r'successRecords.clear();', content)
    content = re.sub(r'//\s*successRecords\.clear\(\);', r'successRecords.clear();', content)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        patched += 1
        print(f"Patched {filepath}")

print(f"Patched {patched} files.")

