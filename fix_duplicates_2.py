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

    # 1. Inject `final currentFailures = <dynamic>[];` before the loop
    if 'final currentFailures = <dynamic>[];' not in content:
        content = content.replace('for (var item in items) {', 'final currentFailures = <dynamic>[];\n    for (var item in items) {')

    # 2. Add currentFailures.add() right after failedRecords.insert()
    # It looks like: failedRecords.insert(0, { ... });
    # We want to match: failedRecords.insert(0, { ... });
    pattern = r'(failedRecords\.insert\(0,\s*\{)(.*?)(\}\);)'
    
    def repl(m):
        return f"{m.group(1)}{m.group(2)}{m.group(3)}\n        currentFailures.add({{{m.group(2)}}});"
    
    # Check if we already injected
    if 'currentFailures.add({' not in content:
        content = re.sub(pattern, repl, content, flags=re.DOTALL)

    # 3. Change `failedRecords.map(` to `currentFailures.map(`
    content = content.replace('final cleanedFailedRecords = failedRecords.map((item) {', 'final cleanedFailedRecords = currentFailures.map((item) {')
    content = content.replace('final cleanedFailedRecords = failedRecords.map((e) {', 'final cleanedFailedRecords = currentFailures.map((e) {')

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        patched += 1
        print(f"Patched {filepath}")

print(f"Patched {patched} files.")

