import re

path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"

with open(path, "r") as f:
    content = f.read()

# Replace the text inside the Text widget and add the arrow
old_str = """                                                Text(
                                                  item["IsBatch"] == "Y"
                                                      ? "View Batches"
                                                      : "View Serials",
                                                  style: TextStyle(
                                                    color: PRIMARY_COLOR,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),"""

new_str = """                                                Text(
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
                                                ),"""

if old_str in content:
    content = content.replace(old_str, new_str)
    with open(path, "w") as f:
        f.write(content)
    print("Replaced!")
else:
    print("Not found.")

