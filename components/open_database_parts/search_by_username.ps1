param(
    [string]$Executable,
    [string]$FilePath
)

# Prompt the user for the username
$username = Read-Host "Enter the username"
Write-Host ""
Write-Host ""

# Construct and execute the command
$command = "$Executable search-td `"$FilePath`" ""Username = '$username'"""
Invoke-Expression $command
