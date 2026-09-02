import os
with open('lib/helper/helper.dart', 'r') as f:
    lines = f.readlines()

# Remove duplicate imports
lines = [l for i, l in enumerate(lines) if not (l.startswith("import 'dart:convert';") and i > 10)]
lines = [l for i, l in enumerate(lines) if not (l.startswith("import 'package:flutter/services.dart';") and i > 10)]

# insert services import at top
if not any("package:flutter/services.dart" in l for l in lines):
    lines.insert(3, "import 'package:flutter/services.dart';\n")

with open('lib/helper/helper.dart', 'w') as f:
    f.writelines(lines)
