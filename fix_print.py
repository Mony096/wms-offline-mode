import re

path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"

with open(path, "r") as f:
    content = f.read()

old_str = """                                          onTap: () {
                                            final isBatch = item["IsBatch"] == "Y";"""

new_str = """                                          onTap: () {
                                            print("Tapped Batch Info!");
                                            final isBatch = item["IsBatch"] == "Y";"""

if old_str in content:
    content = content.replace(old_str, new_str)
    with open(path, "w") as f:
        f.write(content)
    print("Print added!")
else:
    print("Not found.")
