import re

path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"

with open(path, "r") as f:
    content = f.read()

old_str = """                                        child: GestureDetector(
                                          onTap: () {"""

new_str = """                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {"""

if old_str in content:
    content = content.replace(old_str, new_str)
    
    # fix the padding to make it smaller as requested before
    content = content.replace(
        "padding: EdgeInsets.symmetric(\n                                                vertical: 8, horizontal: 12),",
        "padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),"
    )
    content = content.replace(
        "padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),",
        "padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),"
    )

    with open(path, "w") as f:
        f.write(content)
    print("Hit test fixed!")
else:
    print("Not found.")
