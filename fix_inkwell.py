import re

path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"

with open(path, "r") as f:
    content = f.read()

# Replace GestureDetector with InkWell
old_str = """                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {"""

new_str = """                                        child: InkWell(
                                          onTap: () {"""

if old_str in content:
    content = content.replace(old_str, new_str)
    with open(path, "w") as f:
        f.write(content)
    print("Replaced with InkWell!")
else:
    print("GestureDetector not found.")
