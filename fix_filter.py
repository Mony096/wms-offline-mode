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

    # First, let's remove the previous patch from inside the .where((...) {
    pattern = r'\s*final lines = [^\n]+;\n\s*bool hasOpenQty = lines\.any[^\}]+?\}\);\n\s*if \(!hasOpenQty\) return false;\n'
    content = re.sub(pattern, '', content)

    # Next, we want to filter the `state` / `allData` directly when it's accessed from the cubit in the UI!
    # Wait, the easiest way is to redefine `allData` right at the start of `onFilter` or `_applyFilter`
    # And ALSO in the BlocBuilder!
    
    # Actually, in `return_receipt_request_page.dart`, `sale_order_page.dart`, `purchase_return_request_page.dart`, 
    # the logic in BlocBuilder is:
    #                 builder: (context, state) {
    #                   if (filteredData.isEmpty && filter.text.isEmpty) {
    #                     WidgetsBinding.instance.addPostFrameCallback((_) {
    #                       _applyFilter(state);
    #                     });
    #                   }
    # It passes `state` directly to `_applyFilter`.
    # And inside `_applyFilter(List<dynamic> allData)`, it does:
    #     final results = allData.where((bp) {
    # If I just apply the `hasOpenQty` check to `allData` at the VERY BEGINNING of `_applyFilter` (and `onFilter`),
    # it will work perfectly for all of them!
    
    # In purchase_order:
    # void onFilter() {
    #   final allData = _offlineCubit.state;
    
    # In others:
    # void _applyFilter(List<dynamic> allData) {
    # ...
    # Let's replace the first line of the function body.
    
    pattern_apply = r'(void _applyFilter\(List<dynamic> allData\) \{)'
    repl_apply = r'\1\n    allData = allData.where((doc) {\n      final lines = doc[\'DocumentLines\'] as List<dynamic>? ?? [];\n      return lines.any((line) {\n        final qty = double.tryParse(line[\'RemainingOpenQuantity\']?.toString() ?? \'0\') ?? 0.0;\n        return line[\'LineStatus\'] == \'bost_Open\' && qty > 0;\n      });\n    }).toList();\n'
    
    content = re.sub(pattern_apply, repl_apply, content)
    
    pattern_on = r'(void onFilter\(\) \{\n\s*final allData = _offlineCubit\.state;)'
    repl_on = r'\1.where((doc) {\n      final lines = doc[\'DocumentLines\'] as List<dynamic>? ?? [];\n      return lines.any((line) {\n        final qty = double.tryParse(line[\'RemainingOpenQuantity\']?.toString() ?? \'0\') ?? 0.0;\n        return line[\'LineStatus\'] == \'bost_Open\' && qty > 0;\n      });\n    }).toList();\n'
    
    content = re.sub(pattern_on, repl_on, content)
    
    # And we must ensure that `displayList` in purchase_order uses `filteredData` correctly.
    # Wait, in purchase_order_page.dart:
    #          final displayList = filteredData.isEmpty && filter.text.isEmpty && filterInput.text.isEmpty ? state : filteredData;
    # It uses `state` directly! So we also need to filter `state` there!
    pattern_bloc = r'(final displayList = filteredData\.isEmpty[^{]*?\?\s*)state(\s*:\s*filteredData;)'
    repl_bloc = r'\1state.where((doc) { final lines = doc[\'DocumentLines\'] as List<dynamic>? ?? []; return lines.any((line) { final qty = double.tryParse(line[\'RemainingOpenQuantity\']?.toString() ?? \'0\') ?? 0.0; return line[\'LineStatus\'] == \'bost_Open\' && qty > 0; }); }).toList()\2'
    
    content = re.sub(pattern_bloc, repl_bloc, content)

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Fixed {filepath}")

