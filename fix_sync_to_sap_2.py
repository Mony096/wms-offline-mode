import re

filepath = 'lib/sync_to_sap.dart'

with open(filepath, 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if '.clearCachLog();' in line:
        new_lines.append('// ' + line)
    else:
        new_lines.append(line)

with open(filepath, 'w') as f:
    f.writelines(new_lines)

print("Fixed sync_to_sap.dart")
