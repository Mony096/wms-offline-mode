path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"
with open(path, "r") as f:
    lines = f.readlines()

start_idx = -1
end_idx = -1

for i, line in enumerate(lines):
    if "child: GestureDetector(" in line:
        # Check if the next line is onTap
        if i + 1 < len(lines) and "onTap:" in lines[i+1]:
            # This is it. Find the matching closing parenthesis.
            brace_count = 0
            start_idx = i
            for j in range(i, len(lines)):
                brace_count += lines[j].count('(')
                brace_count -= lines[j].count(')')
                if brace_count == 0:
                    end_idx = j
                    break
            break

if start_idx != -1 and end_idx != -1:
    new_btn = """                                        child: InkWell(
                                          onTap: () {
                                            try {
                                              final isBatch = item["IsBatch"] == "Y";
                                              final list = serialOrBatchList.where((e) => e["AbsEntry"] == item["BinID"]).toList();
                                              _showBatchSerialDialog(context, item, list, isBatch);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item["IsBatch"] == "Y" ? "Batch Info" : "Serial Info",
                                                  style: TextStyle(
                                                    color: PRIMARY_COLOR,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 12,
                                                  color: PRIMARY_COLOR,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
"""
    del lines[start_idx:end_idx+1]
    lines.insert(start_idx, new_btn)
    with open(path, "w") as f:
        f.writelines(lines)
    print("Replaced button properly!")
else:
    print("Could not find button.")

