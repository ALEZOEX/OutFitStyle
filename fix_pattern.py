import re

with open('/root/OutFitStyle/server/internal/infrastructure/persistence/postgres/pg/clothing_repository.go', 'r') as f:
    content = f.read()

# Удаляем неправильную вставку
content = re.sub(r'\tif pattern != nil \{\n\t\titem\.Pattern = \*pattern\n\t\}', '', content)

with open('/root/OutFitStyle/server/internal/infrastructure/persistence/postgres/pg/clothing_repository.go', 'w') as f:
    f.write(content)

print('Fixed')
