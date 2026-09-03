import os
import re

files = [
    "lib/feature/inbound/good_receipt_po/presentation/cubit/good_receipt_po_offline_cubit.dart",
    "lib/feature/inbound/return_receipt/presentation/cubit/return_receipt_offline_cubit.dart",
    "lib/feature/outbounce/delivery/presentation/cubit/delivery_offline_cubit.dart",
    "lib/feature/outbounce/purchase_return/presentation/cubit/purchase_return_offline_cubit.dart"
]

for path in files:
    with open(path, "r") as f:
        content = f.read()

    # Find the multiline signature and add progressNotifier
    # The signature looks like `context) async {` at the end
    
    content = content.replace(
        "BuildContext context) async {",
        "BuildContext context, {ValueNotifier<String>? progressNotifier}) async {"
    )
    
    with open(path, "w") as f:
        f.write(content)
    
    print(f"Fixed {path}")

