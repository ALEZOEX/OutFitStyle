import re

# Read the file
with open('C:/Users/Admin/GolandProjects/outfitstyle/server/internal/core/application/services/clothing_item_service.go', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace all instances of .Translate(ctx, param1, param2, param3) with .TranslateSingle(ctx, param1, param3)
# This pattern matches: .Translate(ctx, parameter, parameter, parameter)
pattern = r'\.Translate\(ctx, ([^,]+), ([^,]+), ([^\)]+)\)'
replacement = r'.TranslateSingle(ctx, \1, \3)'

content = re.sub(pattern, replacement, content)

# Write the file back
with open('C:/Users/Admin/GolandProjects/outfitstyle/server/internal/core/application/services/clothing_item_service.go', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed all translation calls in clothing_item_service.go")