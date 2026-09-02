import os
import re

files_to_patch = [
    'lib/feature/outbounce/purchase_return/presentation/sync_log.dart',
    'lib/feature/outbounce/good_issue/presentation/sync_log.dart',
    'lib/feature/outbounce/delivery/presentation/sync_log.dart',
    'lib/feature/counting/bin_count/presentation/sync_log.dart',
    'lib/feature/counting/physical_count/presentation/sync_log.dart',
    'lib/feature/counting/quick_count/presentation/sync_log_cycle_count.dart',
    'lib/feature/counting/quick_count/presentation/sync_log.dart',
    'lib/feature/inbound/return_receipt/presentation/sync_log.dart',
    'lib/feature/inbound/good_receipt_po/presentation/sync_log.dart',
    'lib/feature/inbound/good_receipt_po/presentation/sync_log_quick.dart',
    'lib/feature/inbound/good_receipt/presentation/sync_log.dart',
    'lib/feature/inbound/put_away/presentation/sync_log.dart'
]

for filepath in files_to_patch:
    with open(filepath, 'r') as f:
        content = f.read()

    if "helper.dart" not in content:
        # insert it after the first import
        content = re.sub(r'(import \'.*?\';)', r"\1\nimport 'package:wms_mobile/helper/helper.dart';", content, count=1)
        
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Added helper import to {filepath}")

