# PowerShell скрипт для рекурсивного вывода всех файлов в папке клиента в текстовый файл

$outputFile = "client_files_structure.txt"
$basePath = "D:\outfitstyle\client"

# Очистим старый файл, если он существует
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# Получаем все файлы рекурсивно и записываем их пути в текстовый файл
Get-ChildItem -Path $basePath -Recurse -File | ForEach-Object {
    $_.FullName | Out-File -FilePath $outputFile -Append
    # Добавляем содержимое файла
    Get-Content $_.FullName | Out-File -FilePath $outputFile -Append
    # Добавляем разделитель
    "========================================" | Out-File -FilePath $outputFile -Append
} 

Write-Host "Файлы клиента собраны в $outputFile"