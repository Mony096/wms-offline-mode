import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # The python script broke things in two ways:
    # 1. literal \' inside ${}
    # 2. literal \1 or something hidden?
    # Let's just remove the problematic insertions and re-do them correctly if needed.
    
    original_content = content
    
    # Fix the weird string
    content = content.replace(r"[\'Comments']", "['Comments']")
    content = content.replace(r"[\'Remarks']", "['Remarks']")
    content = content.replace(r"\'-\'", "'-'")
    
    # Let's just replace all literal \1 characters that might have been inserted.
    content = content.replace("\\1", " ")
    content = content.replace("\\2", "\n                            const SizedBox(height: 10),\n                            // --- Items list")

    # The exact string added by mistake has weird spaces, let's just clean it up if there are duplicates.
    # Because I manually replaced some of them before the python script ran, or python ran twice.
    # We will just replace any literal "\" followed by "1" with space.
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed {filepath}")

for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))

