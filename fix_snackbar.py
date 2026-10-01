import re

path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"

with open(path, "r") as f:
    content = f.read()

old_str = """                                        child: InkWell(
                                          onTap: () {"""

new_str = """                                        child: InkWell(
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Loading...")));
                                            try {"""

old_str2 = """                                            _showBatchSerialDialog(context, item, list, isBatch);
                                          },"""

new_str2 = """                                            _showBatchSerialDialog(context, item, list, isBatch);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                            }
                                          },"""

if old_str in content:
    content = content.replace(old_str, new_str)
    content = content.replace(old_str2, new_str2)
    with open(path, "w") as f:
        f.write(content)
    print("Snackbar added!")
else:
    print("InkWell not found.")
