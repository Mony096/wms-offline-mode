import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Look for Icon(icon, color: color, size: 20)
    # Note: size could be different, so let's match flexibly
    pattern = r'(\s*)Icon\(icon,\s*color:\s*color,\s*size:\s*\d+\),?'
    
    if not re.search(pattern, content):
        return False
        
    def repl(m):
        indent = m.group(1)
        original = m.group(0).strip().rstrip(',')
        return f"{indent}GestureDetector({indent}  onTap: () {{\n{indent}    showJsonDialog(context, record);\n{indent}  }},\n{indent}  child: {original},\n{indent}),"

    new_content = re.sub(pattern, repl, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        return True
    return False

count = 0
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.startswith('sync_log') and file.endswith('.dart'):
            if fix_file(os.path.join(root, file)):
                print(f"Patched {os.path.join(root, file)}")
                count += 1

print(f"Total files patched: {count}")

