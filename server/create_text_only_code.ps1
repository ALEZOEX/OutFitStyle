# PowerShell скрипт для сбора только текстовых файлов серверной части в один файл

$sourceDir = "C:\Users\Admin\GolandProjects\outfitstyle\server"
$outputFile = "C:\Users\Admin\GolandProjects\outfitstyle\server\full_server_code_text_only.txt"

# Удаляем старый файл, если он существует
if (Test-Path $outputFile) {
    Remove-Item $outputFile -Force
}

# Текстовые расширения файлов
$textExtensions = @('.go', '.py', '.sql', '.yaml', '.yml', '.json', '.md', '.txt', '.sh', '.bat', '.toml', '.lock', '.mod', '.sum', '.xml', '.html', '.css', '.js', '.ts', '.dart', '.env', '.csv', '', '.dockerignore', '.example', '.ps1', '.kaggle', '.prod', '.train')

# Получаем все файлы в директории рекурсивно
$files = Get-ChildItem -Path $sourceDir -Recurse -File | Where-Object { $textExtensions -contains $_.Extension }

foreach ($file in $files) {
    # Добавляем разделитель с именем файла
    Add-Content -Path $outputFile -Value ("--- " + $file.FullName.Replace($sourceDir, "") + " ---`r`n") -Encoding UTF8
    
    try {
        # Читаем содержимое файла, пробуя разные кодировки
        $content = $null
        
        # Пробуем разные кодировки
        $encodings = @([System.Text.Encoding]::UTF8, [System.Text.Encoding]::ASCII, [System.Text.Encoding]::Unicode, [System.Text.Encoding]::UTF7, [System.Text.Encoding]::UTF32)
        
        foreach ($encoding in $encodings) {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
                $content = $encoding.GetString($bytes)
                
                # Проверяем, содержит ли результат непечатаемые символы, которые могут указывать на бинарный файл
                $isBinary = $false
                $nullCharCount = 0
                foreach ($char in $content.ToCharArray()) {
                    if ([int]$char -eq 0) {
                        $nullCharCount++
                    }
                    if ([int]$char -lt 8 -or ([int]$char -gt 14 -and [int]$char -lt 32) -and [int]$char -ne 9 -and [int]$char -ne 10 -and [int]$char -ne 13) {
                        $isBinary = $true
                        break
                    }
                }
                
                # Если слишком много нулевых байтов или много непечатаемых символов, это, вероятно, бинарный файл
                if ($nullCharCount / $content.Length -gt 0.3 -or $isBinary) {
                    $content = $null
                } else {
                    break
                }
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
            Add-Content -Path $outputFile -Value "# [SKIPPED: Likely binary content or encoding issues]`r`n" -Encoding UTF8
        }
    }
    catch {
        Add-Content -Path $outputFile -Value "# [ERROR: $($_.Exception.Message)]`r`n" -Encoding UTF8
    }
    
    # Добавляем пустую строку после каждого файла
    Add-Content -Path $outputFile -Value "`r`n" -Encoding UTF8
}