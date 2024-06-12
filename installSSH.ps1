# Add OpenSSH.Client if not already installed
$sshCapability = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH.Client*' }
if (!$sshCapability) {
    Add-WindowsCapability -Online -Name OpenSSH.Client*
}