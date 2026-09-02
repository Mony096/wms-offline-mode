import os
import glob
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Skip if already patched
    if 'Remark' in content and 'record[' in content:
        return

    is_counting = "counting" in filepath
    remark_key = "Remarks" if is_counting else "Comments"
    original_content = content
    
    # physical count sync fail / review offline save
    # _buildRow("Warehouse", getWarehouseName(context, record['InventoryCountingLines'][0]['WarehouseCode'] ?? '')),
    pattern = r'(_buildRow\(\s*"Warehouse"\s*,\s*[^)]+\)\s*\),)'
    if re.search(pattern, content):
        replacement = r'\1\n                                  const SizedBox(height: 5),\n                                  _buildRow("Remark", record[\'' + remark_key + '\'] ?? \'\'),'
        content = re.sub(pattern, replacement, content)
        
    # Another pattern where the comma might be differently placed or no comma
    pattern2 = r'(_buildRow\(\s*"Warehouse"\s*,\s*[^;]+\)\s*\))'
    if re.search(pattern2, content) and not re.search(pattern, original_content):
        replacement = r'\1,\n                                  const SizedBox(height: 5),\n                                  _buildRow("Remark", record[\'' + remark_key + '\'] ?? \'\')'
        content = re.sub(pattern2, replacement, content)

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Patched {filepath}")

for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.startswith('sync_log') or file.startswith('sync_faild') or file.startswith('review_offline'):
            process_file(os.path.join(root, file))

