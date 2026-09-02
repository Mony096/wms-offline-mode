import os
import re

# 1. FIX CUBITS
cubit_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('offline_cubit.dart') and 'failed' not in file:
            cubit_files.append(os.path.join(root, file))

for filepath in cubit_files:
    with open(filepath, 'r') as f:
        content = f.read()

    if 'void post(' not in content and 'Future<void> post(' not in content:
        continue

    # Comment out clears
    content = re.sub(r'(?<!// )failedRecords\.clear\(\);', r'// failedRecords.clear();', content)
    content = re.sub(r'(?<!// )successRecords\.clear\(\);', r'// successRecords.clear();', content)
    content = re.sub(r'(?<!//)failedRecords\.clear\(\);', r'// failedRecords.clear();', content)
    content = re.sub(r'(?<!//)successRecords\.clear\(\);', r'// successRecords.clear();', content)

    # Change add to insert(0, )
    content = re.sub(r'failedRecords\.add\(', 'failedRecords.insert(0, ', content)
    content = re.sub(r'successRecords\.add\(', 'successRecords.insert(0, ', content)

    # Inject logId
    def repl_logid(match):
        prefix = match.group(1)
        timestamp_line = match.group(2)
        return f"{prefix}{timestamp_line}\n{prefix}'logId': uuid.v4(),"
    content = re.sub(r'^([ \t]*(?://[ \t]*)?)([\'"]timestamp[\'"]\s*:\s*[^\n,]+,?)', repl_logid, content, flags=re.MULTILINE)

    # Add removeMemoryLog
    if 'void removeMemoryLog' not in content:
        remove_method = """
  void removeMemoryLog(String logId) {
    failedRecords.removeWhere((item) => item['logId'] == logId || item['failId'] == logId);
    successRecords.removeWhere((item) => item['logId'] == logId || item['failId'] == logId);
    emit(List.from(state)); // trigger rebuild
  }
"""
        last_brace_idx = content.rfind('}')
        if last_brace_idx != -1:
            content = content[:last_brace_idx] + remove_method + "\n}\n"

    with open(filepath, 'w') as f:
        f.write(content)

# 2. FIX SYNC LOG UI (Icons, JSON Dialog, Clear All, Remove)
ui_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.startswith('sync_log') and file.endswith('.dart'):
            ui_files.append(os.path.join(root, file))

for filepath in ui_files:
    with open(filepath, 'r') as f:
        content = f.read()

    # Add import
    if "import 'package:wms_mobile/helper/helper.dart';" not in content:
        content = "import 'package:wms_mobile/helper/helper.dart';\n" + content

    # Change context.read<...OfflineCubit> to watch
    content = re.sub(
        r'(final\s+cubit\s*=\s*context\.)read(<[a-zA-Z0-9_]+OfflineCubit>\(\);)',
        r'\1watch\2',
        content,
        count=1
    )

    # Add Clear All to AppBar
    # Look for AppBar( ... title: ... )
    if 'actions: [' not in content:
        content = re.sub(
            r'(appBar:\s*AppBar\([\s\S]*?)(elevation:\s*\d+,?)',
            r'\1\2\n        actions: [\n          IconButton(\n            icon: const Icon(Icons.delete_sweep, color: Colors.white),\n            onPressed: () { cubit.clearCachLog(); },\n          ),\n        ],',
            content,
            count=1 # Only first AppBar
        )

    # Fix error icons
    # Find warning icon and wrap in row
    # The original was: Icon(Icons.warning, ...) or Icon(icon, ...)
    # If not already GestureDetector
    if 'GestureDetector(' not in content or 'showJsonDialog' not in content:
        # Just replace the icon building logic.
        # But wait, earlier I used a python script that found `Icon(icon, color: color, size: 20)`
        pattern_icon = r'(Icon\(icon,\s*color:\s*color,\s*size:\s*20\))'
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
                                    GestureDetector(
                                      onTap: () {
                                        showJsonDialog(context, record);
                                      },
                                      child: \1,
                                    ),
                                  ],
                                )'''
        content = re.sub(pattern_icon, replacement, content)

    with open(filepath, 'w') as f:
        f.write(content)

