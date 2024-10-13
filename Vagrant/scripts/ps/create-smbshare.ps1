# Run this on CD-SRV
# $Parameters = @{
#     Name       = 'Secret'
#     Path       = 'C:\Secret'
#     FullAccess = 'Child\Domain Users', 'Everyone'
# }
# New-SmbShare @Parameters

# Define user/group with FullAccess (replace with your actual users/groups)
# $FullAccessUsers = "Child\Domain Users"
# $FullAccessUsers = "Everyone"
$FullAccessUsers = "child\ghana.bassi"

# Create the SMB share with FullAccess for specified users/groups
New-SmbShare -Name "Pesonal" -Path "C:\Secret" -FullAccess $FullAccessUsers
