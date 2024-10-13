# This scripts installs the Network File Share on the host

# Install NFS on the server
Import-Module ServerManager
Add-WindowsFeature FS-NFS-Service
Import-Module NFS

# Create NFS file share
# New-NfsShare -Name nfs1 -Path C:\shares\nfsfolder