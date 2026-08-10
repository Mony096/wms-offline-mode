import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # 1. Add input formatters to InputCol with controller: quantity,
    # Look for "controller: quantity," and insert inputFormatters if not present
    if 'inputFormatters: [ThousandsSeparatorInputFormatter()' not in content:
        content = re.sub(
            r'(controller:\s*quantity,\s*)',
            r'\1\n                inputFormatters: [ThousandsSeparatorInputFormatter()],\n',
            content
        )

    # 2. Format assignments
    content = re.sub(
        r'(quantity|inWhsQty|variance)\.text\s*=\s*getDataFromDynamic\(([^)]+)\);',
        r'\1.text = formatQuantity(getDataFromDynamic(\2));',
        content
    )
    
    # 3. Handle double.parse(...)
    # specifically: double.parse(quantity.text.isEmpty ? "0" : quantity.text) -> parseQuantity(quantity.text)
    content = re.sub(
        r'double\.parse\s*\(\s*(quantity|inWhsQty|variance)\.text\.isEmpty\s*\?\s*"0"\s*:\s*\1\.text\s*\)',
        r'parseQuantity(\1.text)',
        content
    )
    # double.parse(quantity.text) -> parseQuantity(quantity.text)
    content = re.sub(
        r'double\.parse\s*\(\s*(quantity|inWhsQty|variance)\.text\s*\)',
        r'parseQuantity(\1.text)',
        content
    )
    
    # 4. JSON construction for SAP
    # "Quantity": quantity.text -> "Quantity": quantity.text.replaceAll(',', '')
    content = re.sub(
        r'("Quantity"\s*:\s*quantity\.text),',
        r'"Quantity": quantity.text.replaceAll(\',\', \'\'),',
        content
    )
    content = re.sub(
        r'("InWhsQty"\s*:\s*inWhsQty\.text),',
        r'"InWhsQty": inWhsQty.text.replaceAll(\',\', \'\'),',
        content
    )
    content = re.sub(
        r'("Variance"\s*:\s*variance\.text),',
        r'"Variance": variance.text.replaceAll(\',\', \'\'),',
        content
    )

    if original != content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('screen.dart') or file.endswith('page.dart'):
            process_file(os.path.join(root, file))

