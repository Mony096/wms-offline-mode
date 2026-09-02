import os
import re

files_to_patch = [
    'lib/feature/inbound/purchase_order/presentation/purchase_order_page.dart',
    'lib/feature/inbound/return_receipt_request/presentation/return_receipt_request_page.dart',
    'lib/feature/outbounce/sale_order/presentation/sale_order_page.dart',
    'lib/feature/outbounce/purchase_return_request/presentation/purchase_return_request_page.dart'
]

for filepath in files_to_patch:
    with open(filepath, 'r') as f:
        content = f.read()
        
    if "hasOpenQty" in content:
        print(f"Skipping {filepath} (already patched)")
        continue

    # regex to find: final results = allData.where((varName) {
    # It might span lines, but usually is one line. Let's just look for `allData.where((`
    pattern = r'(final\s+results\s*=\s*allData\.where\s*\(\s*\(\s*([a-zA-Z0-9_]+)\s*\)\s*\{)'
    
    def repl(m):
        var_name = m.group(2)
        added_code = f"""
      final lines = {var_name}['DocumentLines'] as List<dynamic>? ?? [];
      bool hasOpenQty = lines.any((line) {{
        final qty = double.tryParse(line['RemainingOpenQuantity']?.toString() ?? '0') ?? 0.0;
        return line['LineStatus'] == 'bost_Open' && qty > 0;
      }});
      if (!hasOpenQty) return false;
"""
        return m.group(1) + added_code

    new_content = re.sub(pattern, repl, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Patched {filepath}")
    else:
        print(f"Failed to patch {filepath}")

