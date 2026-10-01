path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"

with open(path, "r") as f:
    lines = f.readlines()

start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if "//Serial///////////////////////////" in line:
        start_idx = i
    if "// //End11111111111111" in line:
        end_idx = i
        break

if start_idx != -1 and end_idx != -1:
    new_button_block = """                                  if (item["IsSerial"] == "Y" || item["IsBatch"] == "Y")
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
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
                                        ),
                                      ),
                                    ),
"""

    dialog_func = """
  void _showBatchSerialDialog(BuildContext context, Map<String, dynamic> item, List<dynamic> list, bool isBatch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBatch ? "Batch Details" : "Serial Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PRIMARY_COLOR),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(child: Text("No data found.", style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        padding: EdgeInsets.all(16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final e = list[index];
                          return Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: PRIMARY_COLOR.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(isBatch ? Icons.inventory_2 : Icons.qr_code_2, color: PRIMARY_COLOR, size: 20),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getDataFromDynamic(e["Batch_Serial"]),
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    if (isBatch && getDataFromDynamic(e['ExpDate']).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          "Exp: ${getDataFromDynamic(e['ExpDate'])}",
                                          style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formatQuantity(isBatch ? e['Quantity'] : 1),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
"""

    del lines[start_idx:end_idx+1]
    lines.insert(start_idx, new_button_block)

    # find where to inject method
    content_header_idx = -1
    for i, line in enumerate(lines):
        if "class ContentHeader" in line:
            content_header_idx = i
            break
            
    if content_header_idx != -1:
        for i in range(content_header_idx - 1, -1, -1):
            if lines[i].strip() == "}":
                lines.insert(i, dialog_func)
                break
                
    with open(path, "w") as f:
        f.writelines(lines)
    print("Patched!")
else:
    print("Markers not found.")

