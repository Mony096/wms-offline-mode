import os
import glob
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Determine if it uses "Comments" or "Remarks" based on path
    is_counting = "counting" in filepath
    remark_key = "Remarks" if is_counting else "Comments"

    original_content = content
    
    # 1. review_offline_save & sync_faild_log pattern:
    # _buildRow("Warehouse", record['WarehouseCode'] ?? ''),
    # or record['FromWarehouse']
    
    pattern1 = r'(_buildRow\(\s*"Warehouse"\s*,\s*[^)]+\s*\),)'
    if re.search(pattern1, content):
        replacement1 = r'\1\n                                  const SizedBox(height: 5),\n                                  _buildRow("Remark", record[\'' + remark_key + '\'] ?? \'\'),'
        content = re.sub(pattern1, replacement1, content)

    # 2. sync_log pattern (some have Builder returning Text("Warehouse : $display"), then SizedBox(height: 10))
    # It's tricky to find the exact end of the Builder. We can look for:
    # "Warehouse          :" or "Warehouse :" or "Warehouse : $display"
    # followed by const SizedBox(height: 10),
    
    # Let's try to match the exact SizedBox before Items list.
    pattern2 = r'(\s+)(const SizedBox\(height: 10\),\s+// --- Items list)'
    if re.search(pattern2, content):
        replacement2 = r'\1const SizedBox(height: 4),\1Text(\1  "Remark : ${record[\'' + remark_key + '\'] ?? \'-\'}",\1  style: const TextStyle(fontSize: 13, color: Colors.black54),\1),\1\2'
        content = re.sub(pattern2, replacement2, content)

    # Put Away sync log has:
    #                                  "Warehouse :",
    #                                  style: TextStyle(
    #                                      fontWeight: FontWeight.w600,
    #                                      fontSize: 14),
    #                                ),
    #                                Builder(
    # ...
    #                                )
    #                              ],
    #                            ),
    #                            const SizedBox(
    #                              height: 10,
    #                            ),
    #                            const Text(
    #                              "Items:",
    
    pattern3 = r'(\s+)(const SizedBox\(\s*height: 10,?\s*\),?\s*const Text\(\s*"Items:",)'
    if re.search(pattern3, content) and not re.search(pattern2, content):
        replacement3 = r'\1const SizedBox(height: 4),\1Text(\1  "Remark : ${record[\'' + remark_key + '\'] ?? \'-\'}",\1  style: const TextStyle(fontSize: 13, color: Colors.black54),\1),\1\2'
        content = re.sub(pattern3, replacement3, content)

    # Physical count sync log:
    #                                  style: const TextStyle(fontSize: 13, color: Colors.black54),
    #                                );
    #                              },
    #                            ),
    #                            const SizedBox(height: 10),
    #
    #                            // --- Items list
    
    # If content changed, save it
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Patched {filepath}")

# Find all sync_log, sync_faild_log, review_offline_save files
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.startswith('sync_log') or file.startswith('sync_faild') or file.startswith('review_offline'):
            process_file(os.path.join(root, file))

