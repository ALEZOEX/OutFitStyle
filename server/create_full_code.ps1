# PowerShell скрипт для сбора всех файлов серверной части в один файл с правильной обработкой кодировок

$sourceDir = "C:\Users\Admin\GolandProjects\outfitstyle\server"
$outputFile = "C:\Users\Admin\GolandProjects\outfitstyle\server\full_server_code_final.txt"

# Удаляем старый файл, если он существует
if (Test-Path $outputFile) {
    Remove-Item $outputFile -Force
}

# Получаем все файлы в директории рекурсивно
$files = Get-ChildItem -Path $sourceDir -Recurse -File

foreach ($file in $files) {
    # Пропускаем бинарные файлы и файлы с неподдерживаемыми расширениями
    $binaryExtensions = @('.exe', '.dll', '.so', '.dylib', '.jar', '.war', '.zip', '.tar', '.gz', '.rar', '.7z', '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico', '.pdf', '.doc', '.docx', '.xls', '.xlsx')
    if ($binaryExtensions -contains $file.Extension) {
        continue
    }

    # Добавляем разделитель с именем файла
    Add-Content -Path $outputFile -Value ("--- " + $file.FullName + " ---`r`n") -Encoding UTF8
    
    try {
        # Читаем содержимое файла, пробуя разные кодировки
        $content = $null
        
        # Пробуем разные кодировки
        $encodings = @('UTF8', 'ASCII', 'Unicode', 'UTF7', 'UTF32')
        
        foreach ($encoding in $encodings) {
            try {
                $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::$encoding)
                break
            }
            catch {
                continue
            }
        }
        
        if ($content -ne $null) {
            # Записываем содержимое файла
            Add-Content -Path $outputFile -Value $content -Encoding UTF8
        } else {
            # Если не удалось прочитать, добавляем сообщение
            Add-Content -Path $outputFile -Value "# [ERROR: Could not read file with any encoding]`r`n" -Encoding UTF8
        }
    }
    catch {
        Add-Content -Path $outputFile -Value "# [ERROR: $($_.Exception.Message)]`r`n" -Encoding UTF8
    }
    
    # Добавляем пустую строку после каждого файла
    Add-Content -Path $outputFile -Value "`r`n" -Encoding UTF8
}