import re

path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"

with open(path, "r") as f:
    content = f.read()

old_str = """                                            decoration: BoxDecoration(
                                              color: PRIMARY_COLOR
                                                  .withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: PRIMARY_COLOR
                                                      .withOpacity(0.2)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  item["IsBatch"] == "Y"
                                                      ? Icons
                                                          .inventory_2_outlined
                                                      : Icons
                                                          .qr_code_2_outlined,
                                                  size: 16,
                                                  color: PRIMARY_COLOR,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  item["IsBatch"] == "Y"
                                                      ? "Batch Info"
                                                      : "Serial Info",
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
                                            ),"""

new_str = """                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item["IsBatch"] == "Y"
                                                      ? "Batch Info"
                                                      : "Serial Info",
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
                                            ),"""

if old_str in content:
    content = content.replace(old_str, new_str)
    # also remove the padding from the container if needed.
    # The padding is: padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    content = content.replace(
        "padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),", 
        "padding: EdgeInsets.symmetric(vertical: 4),"
    )
    with open(path, "w") as f:
        f.write(content)
    print("Replaced!")
else:
    print("Not found.")

