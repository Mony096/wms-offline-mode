path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"
with open(path, "r") as f:
    content = f.read()

# Replace the button style
old_btn = """                                        child: GestureDetector(
                                          onTap: () {
                                            final isBatch = item["IsBatch"] == "Y";
                                            final list = serialOrBatchList.where((e) => e["AbsEntry"] == item["BinID"]).toList();
                                            _showBatchSerialDialog(context, item, list, isBatch);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: PRIMARY_COLOR.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: PRIMARY_COLOR.withOpacity(0.2)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  item["IsBatch"] == "Y" ? Icons.inventory_2_outlined : Icons.qr_code_2_outlined,
                                                  size: 16,
                                                  color: PRIMARY_COLOR,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  item["IsBatch"] == "Y" ? "View Batches" : "View Serials",
                                                  style: TextStyle(
                                                    color: PRIMARY_COLOR,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),"""

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
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                                        ),"""

if old_btn in content:
    content = content.replace(old_btn, new_btn)
    with open(path, "w") as f:
        f.write(content)
    print("Replaced!")
else:
    print("Not found.")
