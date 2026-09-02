import os
import re

cubit_files = []
for root, dirs, files in os.walk('lib/feature'):
    for file in files:
        if file.endswith('offline_cubit.dart') and 'failed' not in file:
            cubit_files.append(os.path.join(root, file))

patched = 0

for filepath in cubit_files:
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Strategy: 
    # 1. We know `items` is the list of drafts.
    # 2. We can just use dart's Set to filter `failedRecords`!
    # Instead of injecting `currentFailures` inside the loop, we can just do:
    # final currentSyncSaveIds = items.map((e) => e['SaveId']).toSet();
    # final currentFailures = failedRecords.where((e) => currentSyncSaveIds.contains(e['SaveId'])).toList();
    # Wait, what if there are older logs with the SAME SaveId? We only want ONE per SaveId!
    # So we can just take the first occurrence of each SaveId in failedRecords!
    
    # Actually, we can just do:
    # final currentFailures = items.map((e) => failedRecords.firstWhere((f) => f['SaveId'] == e['SaveId'], orElse: () => null)).where((e) => e != null).toList();
    
    # Wait! If an item SUCCEEDED, it won't be in failedRecords for this batch!
    # `items` has ALL drafts. `failedRecords` has all failed drafts.
    # If we map `items` to `failedRecords` using SaveId, it perfectly extracts the failed ones!
    # BUT wait, what if an item failed YESTERDAY, but SUCCEEDED today?
    # If it succeeded today, it was inserted into `successRecords`.
    # And it's STILL in `failedRecords` from yesterday!
    # So if we map `items` to `failedRecords`, we might accidentally extract the failure from yesterday, even though it succeeded today!
    
    # Therefore, tracking `currentFailures` INSIDE the loop is the ONLY 100% correct way.
    
    # Let's do it with a simple state machine.
    lines = content.split('\n')
    new_lines = []
    
    in_post = False
    in_catch = False
    
    for i, line in enumerate(lines):
        # 1. Find `for (var item in items) {`
        if 'void post(' in line or 'Future<void> post(' in line:
            if not line.strip().startswith('//'):
                in_post = True
                
        if in_post and 'for (var item in items) {' in line and not line.strip().startswith('//'):
            # Only inject if not already there
            if i > 0 and 'final currentFailures' not in lines[i-1]:
                new_lines.append('    final currentFailures = <dynamic>[];')
        
        new_lines.append(line)
        
        # 2. Track catch block inside post
        if in_post and '} catch (e) {' in line and not line.strip().startswith('//'):
            in_catch = True
            
        # 3. Inside catch, find the end of `failedRecords.insert(0, { ... });`
        if in_catch and '});' in line and not line.strip().startswith('//'):
            # Check if it was failedRecords
            # We can just inject currentFailures.add right after.
            # Wait, what if the `});` was for something else? 
            # In these cubits, it's ALWAYS `failedRecords.insert(0, { ... });`
            new_lines.append('        currentFailures.add(failedRecords.first);')
            in_catch = False # reset after injecting
            
        # 4. Replace `failedRecords.map` with `currentFailures.map`
        if in_post and 'final cleanedFailedRecords = failedRecords.map' in line and not line.strip().startswith('//'):
            new_lines[-1] = line.replace('failedRecords.map', 'currentFailures.map')
            
    new_content = '\n'.join(new_lines)
    
    if new_content != original:
        with open(filepath, 'w') as f:
            f.write(new_content)
        patched += 1
        print(f"Patched {filepath}")

print(f"Patched {patched} files.")

