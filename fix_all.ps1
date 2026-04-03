# Скрипт для массовой замены .withOpacity( на .withValues(alpha: 
$files = Get-ChildItem -Path "client\lib\src" -Recurse -Filter "*.dart" | Select-String -Pattern "\.withOpacity\(" | Select-Object -ExpandProperty Path -Unique

foreach ($file in $files) {
    $content = Get-Content $file -Raw
    $content = $content -replace '\.withOpacity\(', '.withValues(alpha: '
    Set-Content $file $content -NoNewline
    Write-Host "Fixed: $file"
}

Write-Host "Done! Total files: $($files.Count)"
