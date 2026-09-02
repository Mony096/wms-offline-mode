import os
import re

# 1. FIX CUBITS: Add emit(List.from(state)); to clearCachLog
cubit_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('offline_cubit.dart') and 'failed' not in file:
            cubit_files.append(os.path.join(root, file))

for filepath in cubit_files:
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    # Look for void clearCachLog() { ... }
    # Since it's exactly:
    # void clearCachLog() {
    #   failedRecords = [];
    #   successRecords = [];
    # }
    if 'void clearCachLog()' in content and 'emit(List.from(state));' not in content.split('void clearCachLog()')[1].split('}')[0]:
        content = re.sub(
            r'(void clearCachLog\(\)\s*\{\s*failedRecords = \[\];\s*successRecords = \[\];\s*)(\})',
            r'\1emit(List.from(state));\n  \2',
            content
        )
        if content != original:
            with open(filepath, 'w') as f:
                f.write(content)

# 2. FIX SYNC LOG UI: Inject Remove Button
ui_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.startswith('sync_log') and file.endswith('.dart'):
            ui_files.append(os.path.join(root, file))

for filepath in ui_files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content

    if 'Icons.close, color: Colors.grey' not in content:
        # We need to wrap the GestureDetector that calls showJsonDialog
        pattern_icon = r'(GestureDetector\([\s\S]*?onTap: \(\) \{[\s\S]*?showJsonDialog\(context, record\);[\s\S]*?\},[\s\S]*?child: Icon\(icon, color: color, size: 20\),[\s\S]*?\))'
        
        replacement = r'''Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                      onPressed: () {
                                        if (record['logId'] != null) {
                                          cubit.removeMemoryLog(record['logId']);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    \1,
                                  ],
                                )'''
        content = re.sub(pattern_icon, replacement, content)
        
        if content != original:
            with open(filepath, 'w') as f:
                f.write(content)

