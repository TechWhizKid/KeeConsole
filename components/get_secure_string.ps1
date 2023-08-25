Param(
    [Parameter(Mandatory=$true)]
    [string]$VariableName
)

# Prompt the user to enter the value as a secure string
$secureString = Read-Host -Prompt " $VariableName" -AsSecureString

# Convert the secure string to plaintext
$plaintext = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))

# Remove invalid characters from the plaintext
$cleanedText = $plaintext -replace '[<>"|]'

# Output the cleaned variable value as a string
Write-Output $cleanedText
