# Run this on CD-SRV server
# Share name
$shareName = "secret"

# Folder path on C drive
$folderPath = "C:\Secret"

# User with read-only access
$readOnlyUser = "child\ghana.bassi"

# Share description (replace with your desired description)
$shareDescription = "This is a private folder for specific use."

# Check if folder exists
if (!(Test-Path -Path $folderPath -PathType Directory)) {
    # Create the folder if not found
    New-Item -ItemType Directory -Path $folderPath
    Write-Host "Folder '$folderPath' created successfully."
}
else {
    Write-Host "Folder '$folderPath' already exists."
}

# Check if share exists
if (!(Get-SmbShare -Name $shareName)) {
    # Create the share with description if it doesn't exist
    New-SmbShare -Name $shareName -Path $folderPath -ReadAccess $readOnlyUser -Description $shareDescription
    Write-Host "Share '$shareName' created successfully."
}
else {
    Write-Host "Share '$shareName' already exists."
}
