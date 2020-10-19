#requires -version 2
<#
.SYNOPSIS
  PowerShell Transcripts Collator
.DESCRIPTION
  Copies PowerShell Transcripts from all hosts in Active Directory to the local machine
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Acidcrash376
  Creation Date:  20/10/2020
  Purpose/Change: Initial Release
  Web:            https://github.com/acidcrash376/PoSH-Transcript-Collator
  
.EXAMPLE
  ./PoSH-Transcripts.ps1
#>




#---------------------------------------------------------[Script Parameters]------------------------------------------------------

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#----------------------------------------------------------[Declarations]----------------------------------------------------------

### pstranscript dir should be the path to the transcript dir without the drive, 
### eg: c:\windows\transcripts -> windows\transcripts
$pstranscriptdir = "Transcripts"

### pslocaltranscript dir should be the path to the transcript dir with the drive
$pslocaltranscript = "c:\Host Transcripts"

$excludedhost = $env:COMPUTERNAME
$computers = Get-ADComputer -filter "Name -ne '$excludedhost'" | Select-Object -ExpandProperty Name

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "      PowerShell Transcript Fetching Tool " -ForegroundColor Yellow 
Write-Host "      =================================== " -ForegroundColor Yellow 
Write-Host ""

foreach ($hosts in $computers) {
    Write-Host "Computer Name: " -ForegroundColor DarkCyan -NoNewline; Write-Host " $hosts"
    $test = Test-NetConnection -ComputerName $hosts
    
    $tab = [char]9
    If (($test).pingsucceeded) {
        Write-Host "Connectivity: $tab" -ForegroundColor DarkCyan -NoNewline; Write-Host "OK" -ForegroundColor Green
        }
        else
        {
        Write-Host "Host: " -ForegroundColor DarkCyan -NoNewline; Write-Host "Unreachable" -ForegroundColor Red
    } 
### Function to test whether the transcript directory exists on the host   
    Function Test-TranscriptDir {
        $hostpath = "\\$hosts\c$\$pstranscriptdir"
        $testpath1 = Test-Path $hostpath
        If ($testpath1) {
            Write-Host "Transcript Dir: " -ForegroundColor DarkCyan -NoNewline; Write-Host "OK" -ForegroundColor Green
            }
            else
            {
            New-Item -Path "$hostpath" -ItemType Directory | Out-Null
            Test-TranscriptDir
        }
    }
### Function to test whether the host transcripts dir exists on the local machine   
    Function Test-LocalDir {
        $localpath = "$pslocaltranscript"
        $testpath2 = Test-Path $localpath
        If ($testpath2) {
            Write-Host "Local Dir: $tab $tab" -ForegroundColor DarkCyan -NoNewline; Write-Host "OK" -ForegroundColor Green
            }
            else
            {
            New-Item -Path $localpath -ItemType Directory | Out-Null
            Test-LocalDir
        }
    }
### Function to test whether the dir for the host exists in the local machines transcript directory
    Function Test-HostLocalDir {
        $localpath = "$pslocaltranscript"
        $hostdir = "$localpath\$hosts"
        $testpath3 = Test-Path $hostdir
        If ($testpath3) {
            Write-Host "Local Host Dir: " -ForegroundColor DarkCyan -NoNewline; Write-Host "OK" -ForegroundColor Green
            }
            else
            {
            New-Item -Path $hostdir -ItemType Directory | Out-Null
            Test-HostLocalDir
            
        }
    }
### Function to copy transcripts from remote host to local host
    Function Copy-Transcripts {
        $hostpath = "\\$hosts\c$\$pstranscriptdir"
        $localpath = "$pslocaltranscript"
        $hostdir = "$localpath\$hosts"
        robocopy /MIR "$hostpath" $hostdir | Out-Null
        Write-Host "Files Copied: $tab" -ForegroundColor DarkCyan -NoNewline; Write-Host "OK" -ForegroundColor Green
    }

    Test-TranscriptDir
    Test-LocalDir
    Test-HostLocalDir
    Copy-Transcripts
}

Write-Host "Complete" -ForegroundColor Yellow
