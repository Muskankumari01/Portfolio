# Simple HTTP Server in PowerShell
$port = 8000
$path = Get-Location

Write-Host "Starting HTTP server on port $port"
Write-Host "Serving files from: $path"
Write-Host "Open your browser and go to: http://localhost:$port"
Write-Host "Press Ctrl+C to stop the server"

try {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath
        $localPath = $localPath.TrimStart('/')
        
        if ($localPath -eq "") {
            $localPath = "index.html"
        }
        
        $filePath = Join-Path $path $localPath
        
        if (Test-Path $filePath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
            $notFound = [System.Text.Encoding]::UTF8.GetBytes("File not found")
            $response.OutputStream.Write($notFound, 0, $notFound.Length)
        }
        
        $response.Close()
    }
} catch {
    Write-Host "Error: $_"
} finally {
    if ($listener) {
        $listener.Stop()
    }
} 