# netsh interface set interface name="Ethernet" disable

# Get the Ethernet adapter information
$ethernetAdapter = Get-NetAdapter -Name "Ethernet"

# Check if the adapter is found
if ($ethernetAdapter) {
    # Check if the adapter is enabled
    if ($ethernetAdapter.Status -eq "Enabled") {
        # Disable the adapter if enabled
        Disable-NetAdapter -Name $ethernetAdapter.Name
        Write-Host "Ethernet adapter disabled."
    }
    else {
        # Message if already disabled
        Write-Host "Ethernet adapter is already disabled."
    }
}
else {
    # Error message if adapter not found
    Write-Error "Ethernet adapter not found. Please verify the name."
}