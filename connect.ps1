# Function to load env variables from a file
function Load-EnvFile {
    param (
        [string]$path
    )

    if (-not (Test-Path $path)) {
        throw "Env file '$path' does not exist."
    }

    $lines = Get-Content -Path $path
    foreach ($line in $lines) {
        if ($line -match '^\s*#') {
            continue
        }
        if ($line -match '^\s*(.+?)\s*=\s*(.+?)\s*$') {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }
}

# Load the env file
$envFilePath = ".\config.env"
Load-EnvFile -path $envFilePath

# Read env variables
$user = [System.Environment]::GetEnvironmentVariable("USER")
$ip = [System.Environment]::GetEnvironmentVariable("IP")
$port = [System.Environment]::GetEnvironmentVariable("PORT")
$RDP1 = [System.Environment]::GetEnvironmentVariable("RDP1")
$FTP1 = [System.Environment]::GetEnvironmentVariable("FTP1")
$h1 = [System.Environment]::GetEnvironmentVariable("H1")
$h1p = [System.Environment]::GetEnvironmentVariable("H1P")
$h2p = [System.Environment]::GetEnvironmentVariable("H2P")
$CompanyName = [System.Environment]::GetEnvironmentVariable("COMPANY_NAME")
$ServerName = [System.Environment]::GetEnvironmentVariable("SERVER_NAME")
$keyPath = [System.Environment]::GetEnvironmentVariable("KEY_PATH")

# Set correct permissions on the private key file
try {
    icacls $keyPath /inheritance:r /grant:r "$($env:USERNAME):(R)" /remove "Everyone" /T
    Write-Host "Permissions set on the key file successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to set permissions on the key file. Please check the file path and permissions manually." -ForegroundColor Red
    Exit
}

$knownHostsPath = "$env:userprofile\.ssh\known_hosts"
$hostFingerprint = (ssh-keygen -l -F $ip | Out-String).Trim()
if (-not $hostFingerprint) {
    ssh-keyscan $ip | Out-File -Append -Encoding utf8 $knownHostsPath
}

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "" # These are needed to prevent the below loop from covering the text
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "****************************************" -ForegroundColor DarkYellow
Write-Host "* Connecting to $CompanyName Servers *" -ForegroundColor DarkYellow
Write-Host "****************************************" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "Establishing link to $ServerName." -ForegroundColor DarkYellow
Write-Host ""

# Prompt user for which tunnels to open
$rdpResponse = Read-Host "Would you like to open the RDP tunnel? (yes/no)"
$ftpResponse = Read-Host "Would you like to open the FTP tunnel? (yes/no)"

# Build SSH command based on user responses
$sshCommand = "ssh -p $port $user@$ip -N"
if ($rdpResponse.Substring(0, 1).ToLower() -eq "y") {
    $sshCommand += " -L ${RDP1}:${h1}:${h1p}"
}
if ($ftpResponse.Substring(0, 1).ToLower() -eq "y") {
    $sshCommand += " -L ${FTP1}:${h1}:${h2p}"
}
$sshCommand += " -i $keyPath"

# Try to start the SSH process
try {
    $sshProcess = Start-Process powershell -ArgumentList "-NoExit", "-Command `"$sshCommand`"" -NoNewWindow -ErrorAction Stop
} catch {
    Write-Host "Failed to establish SSH connection. Please check your credentials and key file." -ForegroundColor Red
    Exit
}

# Set timeout duration in seconds
$timeout = 60

# Check for SSH tunnel connection
$connectedRDP = $false
$connectedFTP = $false
$startTime = Get-Date

while ((-not $connectedRDP -and $rdpResponse.Substring(0, 1).ToLower() -eq "y") -or (-not $connectedFTP -and $ftpResponse.Substring(0, 1).ToLower() -eq "y") -and (New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds -lt $timeout) {
    if ($rdpResponse.Substring(0, 1).ToLower() -eq "y") {
        $connectedRDP = Test-NetConnection -ComputerName $h1 -Port $RDP1 -WarningAction SilentlyContinue | Select-Object -ExpandProperty TcpTestSucceeded
    }
    if ($ftpResponse.Substring(0, 1).ToLower() -eq "y") {
        $connectedFTP = Test-NetConnection -ComputerName $h1 -Port $FTP1 -WarningAction SilentlyContinue | Select-Object -ExpandProperty TcpTestSucceeded
    }
    Start-Sleep -Seconds 1
}

if ((-not $connectedRDP -and $rdpResponse.Substring(0, 1).ToLower() -eq "y") -or (-not $connectedFTP -and $ftpResponse.Substring(0, 1).ToLower() -eq "y")) {
    Write-Host ""
    Write-Host "Connection could not be established within $timeout seconds." -ForegroundColor Red
    Write-Host "Your link to the $CompanyName servers has not been established." -ForegroundColor Red
    Write-Host "Please make sure you have your credentials ready, close this window and try again" -ForegroundColor Red
    Write-Host ""
    Exit # Exits if the tunnel isn't established
}

Write-Host ""
Write-Host "Link to $ServerName Established" -ForegroundColor Green
Write-Host ""
Write-Host "---------------------------------------------------------" -ForegroundColor Blue
Write-Host "If the remote connection doesn't automatically open and" -ForegroundColor Blue
Write-Host "start connecting, Use the below Details to connect to" -ForegroundColor Blue
Write-Host "the relevant services:" -ForegroundColor Blue
Write-Host "---------------------------------------------------------" -ForegroundColor Blue
if ($rdpResponse.Substring(0, 1).ToLower() -eq "y") {
    Write-Host "Remote Desktop Connection:" -ForegroundColor Blue
    Write-Host "IP: $h1" -ForegroundColor Blue
    Write-Host "Port: $RDP1" -ForegroundColor Blue
}
if ($ftpResponse.Substring(0, 1).ToLower() -eq "y") {
    Write-Host "FTP:" -ForegroundColor Blue
    Write-Host "IP: $h1" -ForegroundColor Blue
    Write-Host "Port: $FTP1" -ForegroundColor Blue
}
#Write-Host "User: $user" -ForegroundColor Blue
Write-Host "---------------------------------------------------------" -ForegroundColor Blue
Write-Host "" -ForegroundColor Blue

# Ask the user if they want to open the remote desktop connection
if ($rdpResponse.Substring(0, 1).ToLower() -eq "y") {
    $openRDP = Read-Host "Would you like to open the remote desktop connection now? (yes/no)"
    if ($openRDP.Substring(0, 1).ToLower() -eq "y") {
        Write-Host "Opening remote desktop connection window" -ForegroundColor DarkYellow
        # Open RDP window
        Start-Process mstsc 'connection.rdp'
        Write-Host ""
        Write-Host "Window Opened" -ForegroundColor Green
    } else {
        Write-Host "You chose not to open the remote desktop connection." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Keep this PowerShell window open!" -ForegroundColor Blue
Write-Host "When you close this window, it will close your link to the $CompanyName servers." -ForegroundColor Blue
