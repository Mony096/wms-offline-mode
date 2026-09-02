import os

def clean_file(filepath):
    with open(filepath, 'rb') as f:
        content = f.read()

    # The characters \x01 and \x02 might be present
    original = content
    content = content.replace(b'\x01', b' ')
    content = content.replace(b'\x02', b'\n                            const SizedBox(height: 10),\n                            // --- Items list')

    # Wait, some places might have gotten messed up. 
    if content != original:
        with open(filepath, 'wb') as f:
            f.write(content)
        print(f"Cleaned {filepath}")

for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('.dart'):
            clean_file(os.path.join(root, file))

