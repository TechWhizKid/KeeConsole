param(
    [string]$Executable,
    [string]$FilePath
)

# Prompt the user for the title
$title = Read-Host "Enter the title"
Write-Host ""
Write-Host ""

# Construct and execute the command
$command = "$Executable search-td `"$FilePath`" ""Title = '$title'"""
Invoke-Expression $command
