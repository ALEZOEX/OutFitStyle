# Освобождение места на диске
Get-Process | Where-Object {$_.Path -like "*full_server_code*"} | Stop-Process -Force
Remove-Item "C:\Users\Admin\GolandProjects\outfitstyle\server\full_server_code*.txt" -Force