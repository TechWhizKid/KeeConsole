param(
    [string]$Executable,
    [string]$FilePath
)

# Prompt the user for input
$title = Read-Host "Enter a title"
$username = Read-Host "Enter username"
$password = Read-Host "Enter password"

# Construct and execute the command
$command = "$Executable add-td $FilePath ""Title:$title"" ""Username:$username"" ""Password:$password"""
Invoke-Expression $command
