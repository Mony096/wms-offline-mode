import re

path = "lib/sync_to_sap.dart"
with open(path, "r") as f:
    content = f.read()

# 1. Update SyncItem definition
content = re.sub(
    r'final Future<void> Function\(BuildContext\) onSync;',
    r'final Future<void> Function(BuildContext, [ValueNotifier<String>?]) onSync;',
    content
)

# 2. Update individual sync button inside _buildApiCard
replacement = """                          final progressNotifier = ValueNotifier<String>("Preparing to sync...");
                          MaterialDialog.loading(context, progressNotifier: progressNotifier);
                          try {
                            await item.onSync(context, progressNotifier);"""

content = content.replace(
"""                          MaterialDialog.loading(context);
                          try {
                            await item.onSync(context);""",
replacement
)

# 3. Update all onSync definitions inside the SyncGroups
# To make this foolproof without regex complexity, we can just replace the specific post calls.
# The post calls look like: .post(context.read<FailedCubit>(), context.read<OtherCubit>(), context)
# We can just match `.post(` and trace the closing `);` and insert `progressNotifier: progressNotifier`

def replacer(match):
    full_match = match.group(0)
    new_match = full_match.replace("onSync: (context) async {", "onSync: (context, [progressNotifier]) async {")
    
    # Simple trick: just replace the last ); in the block with , progressNotifier: progressNotifier);
    # Since each onSync block only contains one .post(...) statement ending with );
    new_match = new_match.replace(");", ", progressNotifier: progressNotifier);", 1)
    # wait, this might be risky if there are multiple statements. Let's just use regex on .post
    inner_post_pattern = r'\.post\((.*?)\);'
    def inner_replacer(m):
        args = m.group(1).strip()
        if args.endswith(','):
            return f'.post({args} progressNotifier: progressNotifier);'
        elif args == "":
            return f'.post(progressNotifier: progressNotifier);'
        else:
            return f'.post({args}, progressNotifier: progressNotifier);'
            
    # Let's revert the naive replace and use the regex replace
    new_match = full_match.replace("onSync: (context) async {", "onSync: (context, [progressNotifier]) async {")
    new_match = re.sub(inner_post_pattern, inner_replacer, new_match, flags=re.DOTALL)
    
    return new_match

content = re.sub(r'onSync:\s*\(context\)\s*async\s*\{.*?\.post\(.*?\);.*?\}', replacer, content, flags=re.DOTALL)

# But wait, there is ALSO `item.onSync(context)` inside the GLOBAL _syncAll loop!
# We need to update that to just `item.onSync(context)` or pass `progressNotifier`.
# We ALREADY have `progressNotifier` in _syncAll!
# So we can change `await item.onSync(context);` to `await item.onSync(context, progressNotifier);` inside _syncAll!
# The global one is around `print("🔄 Syncing ${item.name} ($count records)...");`
content = content.replace(
    'await item.onSync(context);',
    'await item.onSync(context, progressNotifier);'
)

with open(path, "w") as f:
    f.write(content)

print(f"Patched {path}")

