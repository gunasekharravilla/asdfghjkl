# Define the log file
$logFile = "F:\Wedding\git_push_log.txt"
$branch = "main"
$startTime = Get-Date

# Get all untracked files recursively
$files = git ls-files --others --exclude-standard | ForEach-Object { Get-Item $_ }

$totalFiles = $files.Count
$processed = 0

# Logging function
function Log-Message {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
    Write-Host $message
}

Log-Message "Starting Git Push Process - Total Files: $totalFiles"

foreach ($file in $files) {
    $processed++
    $remaining = $totalFiles - $processed
    $elapsedTime = (Get-Date) - $startTime
    $timePerFile = $elapsedTime.TotalSeconds / $processed
    $estimatedTimeLeft = $timePerFile * $remaining
    $eta = (Get-Date).AddSeconds($estimatedTimeLeft)

    Log-Message "Processing ($processed/$totalFiles): $($file.FullName)"

    try {
        # Add the file to Git
        git add "$($file.FullName)"
        
        # Commit with a dynamic message
        git commit -m "Added $($file.FullName)"
        
        # Push to GitHub
        git push origin $branch

        # Log successful push
        Log-Message "Successfully pushed: $($file.FullName)"

    } catch {
        # Log errors if any file fails
        Log-Message "Error processing $($file.FullName): $_"
    }

    # Display remaining files and estimated time left
    Log-Message "Remaining: $remaining files | ETA: $eta"

    # Optional delay to prevent Git rate limits
    Start-Sleep -Seconds 2
}

$endTime = Get-Date
$duration = $endTime - $startTime
Log-Message "All files pushed successfully! Total time taken: $($duration.ToString())"
