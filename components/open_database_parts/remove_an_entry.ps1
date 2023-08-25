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
    $entryNo = Read-Host "Enter a valid entry 'No' to remove"
} while (-not (IsValidPositiveNumber $entryNo))

# Construct the command
$command = "$Executable remove-td `"$FilePath`" ""No = '$entryNo'"""

# Execute the command
Invoke-Expression $command
