<#
.SYNOPSIS
    Consolidated Deployment Script for LogMeIn Central Base Plan.
    Installs Huntress EDR -> Verifies Active Status -> Downloads & Runs Cylance Removal Tool.
.LOG FILE
    C:\Windows\Temp\ComTech-Deploy.log
.NOTES
    The '-r' flag has been removed from the Cylance tool execution to protect 
    active users from sudden forced system reboots.
#>

$LogFolder = "C:\Windows\Temp"
$LogFile = Join-Path $LogFolder "ComTech-Deploy.log"

function Write-Log {
    param ([string]$Message)
    if (-not (Test-Path $LogFolder)) {
        New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
    }
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $Message"
    $entry | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Output $entry
}

Write-Log "========================================================="
Write-Log "---- Huntress Install & Cylance Removal Script Started ----"
Write-Log "========================================================="

# Force TLS 1.2 for web downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# -----------------------------------------------------------------
# STEP 1: DOWNLOAD AND INSTALL HUNTRESS
# -----------------------------------------------------------------
$AccountKey = "b108bfd762ba87bc0e6a7733288eb424"
$OrgKey = "taylor"
$HuntressScriptPath = "$env:TEMP\InstallHuntress.ps1"

Write-Log "Downloading Huntress deployment script..."
try {
    (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/huntresslabs/deployment-scripts/main/Powershell/InstallHuntress.powershellv2.ps1', $HuntressScriptPath)
    Write-Log "Huntress script downloaded to $HuntressScriptPath"
    
    Write-Log "Executing Huntress installer..."
    & $HuntressScriptPath -acctkey $AccountKey -orgkey $OrgKey
} catch {
    Write-Log "ERROR: Failed to download or execute Huntress installation wrapper: $_"
    exit 1
}

# -----------------------------------------------------------------
# STEP 2: VERIFY HUNTRESS IS ACTIVE (SAFETY GATE)
# -----------------------------------------------------------------
Write-Log "Waiting 30 seconds for HuntressAgent service to provision..."
Start-Sleep -Seconds 30

$HuntressService = Get-Service -Name "HuntressAgent" -ErrorAction SilentlyContinue

if ($HuntressService -and $HuntressService.Status -eq 'Running') {
    Write-Log "SUCCESS: HuntressAgent service is running and verified."
} else {
    Write-Log "CRITICAL ERROR: HuntressAgent is not detected or not running. Aborting Cylance removal for safety!"
    exit 1
}

# -----------------------------------------------------------------
# STEP 3: DOWNLOAD AND RUN CYLANCE REMOVAL TOOL
# -----------------------------------------------------------------
Write-Log "Proceeding with Cylance removal tool download..."

$archiveUrl   = "https://raw.githubusercontent.com/MtRanchAdmin/ComTech_Public/refs/heads/main/CylanceRemovalToolx64.7z"
$7zaZipUrl    = "https://raw.githubusercontent.com/MtRanchAdmin/ComTech_Public/refs/heads/main/7za.zip"
$downloadPath = "$env:TEMP\CylanceRemovalTool.7z"
$7zaZipPath   = "$env:TEMP\7za.zip"
$7zaExtract   = "$env:TEMP\7zaExtract"
$7zaPath      = "$env:TEMP\7zaExtract\7za.exe"
$extractPath  = "$env:TEMP\CylanceRemovalTool"

try {
    # Download and unzip 7za.exe
    Write-Log "Downloading 7za standalone binary..."
    Invoke-WebRequest -Uri $7zaZipUrl -OutFile $7zaZipPath -UseBasicParsing -ErrorAction Stop

    Write-Log "Extracting 7za.exe..."
    Expand-Archive -Path $7zaZipPath -DestinationPath $7zaExtract -Force

    if (-not (Test-Path $7zaPath)) {
        Write-Log "ERROR: 7za.exe not found after extraction at: $7zaPath"
        exit 1
    }

    # Download Cylance removal archive
    Write-Log "Downloading Cylance Removal Tool archive..."
    Invoke-WebRequest -Uri $archiveUrl -OutFile $downloadPath -UseBasicParsing -ErrorAction Stop

    # Extract using 7za
    Write-Log "Extracting Cylance removal tool..."
    $7zaResult = & $7zaPath x $downloadPath -o"$extractPath" -y 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "ERROR: 7za extraction failed (exit code $LASTEXITCODE): $7zaResult"
        exit 1
    }

    $exePath = Join-Path $extractPath "CylanceRemovalToolx64.exe"
    if (-not (Test-Path $exePath)) {
        Write-Log "ERROR: Removal tool executable not found after extraction at: $exePath"
        exit 1
    }

    Write-Log "Running Cylance removal tool silently (Force flag only, deferred reboot)..."
    # -f is retained to force-delete the product. -r is intentionally excluded to prevent sudden user reboots.
    $process = Start-Process -FilePath $exePath -ArgumentList "-f" -Wait -NoNewWindow -PassThru
    Write-Log "Removal tool exited with code $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        Write-Log "WARNING: Non-zero exit code from removal tool. Cylance may not have been fully removed."
    } else {
        Write-Log "SUCCESS: Cylance removal tool executed successfully."
    }

} catch {
    Write-Log "ERROR during Cylance download or execution phase: $_"
    exit 1
}

# -----------------------------------------------------------------
# STEP 4: CLEANUP TEMPORARY FILES
# -----------------------------------------------------------------
Write-Log "Cleaning up temporary staging files..."
Remove-Item -Path $HuntressScriptPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $downloadPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $7zaZipPath  -Force -ErrorAction SilentlyContinue
Remove-Item -Path $7zaExtract  -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Log "---- Huntress Install & Cylance Removal Script Completed ----"
exit 0