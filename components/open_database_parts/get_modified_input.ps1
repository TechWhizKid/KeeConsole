param(
    [string]$Executable,
    [string]$FilePath
)

# Function to validate if input is a valid positive number
function IsValidPositiveNumber($value) {
    $isValid = $value -match '^\d+$' -and [int]$value -gt 0
    return $isValid
}

# Prompt the user for a valid positive entry number
do {
    $entryNo = Read-Host "Enter a valid entry 'No' to modify"
} while (-not (IsValidPositiveNumber $entryNo))

# Prompt the user to choose what to modify
do {
    Write-Host "Choose what to modify"
    Write-Host "1. Title"
    Write-Host "2. Username"
    Write-Host "3. Password"
    $choice = Read-Host "Enter your choice (1/2/3)"
} while ($choice -notmatch '^[1-3]$')

# Based on the user's choice, modify the appropriate field
switch ($choice) {
    1 {
        $title = Read-Host "Enter new title"
        $command = "$Executable modify-td `"$FilePath`" ""No = $entryNo"" ""Title = '$title'"""
    }
    2 {
        $username = Read-Host "Enter new username"
        $command = "$Executable modify-td `"$FilePath`" ""No = $entryNo"" ""Username = '$username'"""
    }
    3 {
        $password = Read-Host "Enter new password"
        $command = "$Executable modify-td `"$FilePath`" ""No = $entryNo"" ""Password = '$password'"""
    }
}

# Execute the specific command
Invoke-Expression $command
