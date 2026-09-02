import os
import re

ui_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.startswith('sync_log') and file.endswith('.dart'):
            ui_files.append(os.path.join(root, file))

for filepath in ui_files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content

    # 1. Update Clear All button
    pattern_clear_all = r'(onPressed:\s*\(\)\s*\{\s*)(cubit\.clearCachLog\(\);\s*)(\},)'
    replacement_clear_all = r'''\1showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear All Logs'),
                content: const Text('Are you sure you want to clear all sync logs?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      \2
                    },
                    child: const Text('Clear', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ); \3'''
    
    # We only want to apply this if we haven't already applied the dialog
    if "Text('Clear All Logs')" not in content:
        content = re.sub(pattern_clear_all, replacement_clear_all, content)

    # 2. Update Remove by Item button
    pattern_remove_item = r'(onPressed:\s*\(\)\s*\{\s*)(if \(record\[\'logId\'\] != null\) \{\s*cubit\.removeMemoryLog\(record\[\'logId\'\]\);\s*\})(\s*\},\s*\),)'
    replacement_remove_item = r'''\1showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Remove Log'),
                                          content: const Text('Are you sure you want to remove this log?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                \2
                                              },
                                              child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );\3'''
    
    if "Text('Remove Log')" not in content:
        content = re.sub(pattern_remove_item, replacement_remove_item, content)
        
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)

