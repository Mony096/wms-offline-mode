import os
import re

cubit_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('offline_cubit.dart') and 'failed' not in file:
            cubit_files.append(os.path.join(root, file))

for filepath in cubit_files:
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    if 'final cleanedFailedRecords = failedRecords.map(' in content:
        # We need to change what cleanedFailedRecords uses.
        # It's currently using failedRecords.map
        # We can change it to use a filtered list of failedRecords that match the items in THIS sync batch.
        # But wait, items doesn't have failId yet. 
        pass

