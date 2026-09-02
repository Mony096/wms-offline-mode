import re

content = """
    for (var item in items) {
      final startTime = DateTime.now();
      try {
        await postToSAP(
          host: host,
          port: port,
          token: loginToken,
          body: item,
        );
        successRecords.insert(0, {
          ...item,
          'success': "Synced Successfully to SAP",
          'timestamp': startTime.toIso8601String(),
          'logId': uuid.v4(),
        });
        print("✅ Synced: ${item['DocEntry'] ?? 'N/A'}");
      } catch (e) {
        print("🔥 Failed to sync record: $e");
        print(item);
        failedRecords.insert(0, {
          ...item,
          'error': e.toString(),
          'timestamp': startTime.toIso8601String(),
          'logId': uuid.v4(),
          'failId': uuid.v4(),
        });
      }
    }
    // Clean up failed records
    final cleanedFailedRecords = failedRecords.map((item) {
"""

# Let's inject a new list before the loop, and populate it in the catch block.
# 1. find 'for (var item in items) {'
content = content.replace('for (var item in items) {', 'final currentFailures = <dynamic>[];\n    for (var item in items) {')

# 2. find 'failedRecords.insert(0, {' and capture the block inside it.
pattern = r'(failedRecords\.insert\(\0,\s*\{)(.*?)(\}\);)'
# Wait, regex dot doesn't match newline by default, use re.DOTALL
def repl(m):
    return f"{m.group(1)}{m.group(2)}{m.group(3)}\n        currentFailures.add({{{m.group(2)}}});"

content = re.sub(pattern, repl, content, flags=re.DOTALL)

# 3. replace 'failedRecords.map(' with 'currentFailures.map('
content = content.replace('final cleanedFailedRecords = failedRecords.map((item) {', 'final cleanedFailedRecords = currentFailures.map((item) {')

print(content)
