path = "lib/feature/lookup/product_lookup/presentation/product_lookup_screen.dart"

with open(path, "r") as f:
    lines = f.readlines()

# Find _showBatchSerialDialog
start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if "void _showBatchSerialDialog" in line:
        start_idx = i
        break

if start_idx != -1:
    # Find the end of this method. 
    # Since it's 85 lines long, let's just count braces.
    brace_count = 0
    for i in range(start_idx, len(lines)):
        brace_count += lines[i].count('{')
        brace_count -= lines[i].count('}')
        if brace_count == 0:
            end_idx = i
            break

    if end_idx != -1:
        # Extract the method
        method_lines = lines[start_idx:end_idx+1]
        del lines[start_idx:end_idx+1]
        
        # Find where _CreateProductLookUpScreenState ends.
        # It's right before `class ContentHeader`.
        content_header_idx = -1
        for i, line in enumerate(lines):
            if "class ContentHeader" in line:
                content_header_idx = i
                break
        
        if content_header_idx != -1:
            # Find the closing brace of the state class above it
            for i in range(content_header_idx - 1, -1, -1):
                if lines[i].strip() == "}":
                    # Insert right before this closing brace
                    lines = lines[:i] + method_lines + lines[i:]
                    break
        
        with open(path, "w") as f:
            f.writelines(lines)
        print("Fixed location of method.")
    else:
        print("Could not find end of method.")
else:
    print("Could not find start of method.")

