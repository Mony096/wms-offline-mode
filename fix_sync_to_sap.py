import re

filepath = 'lib/sync_to_sap.dart'

with open(filepath, 'r') as f:
    content = f.read()

# Replace any line containing `.clearCachLog();` with nothing, or comment it out.
# Let's just comment it out so it's clear what was changed.
content = re.sub(r'(\s*context\.read<[^>]+>\(\)\.clearCachLog\(\);)', r'//\1', content)

with open(filepath, 'w') as f:
    f.write(content)

print("Fixed sync_to_sap.dart")
