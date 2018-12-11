#Set-ExecutionPolicy RemoteSigned
Import-Module AzureRM

$global:domainCred = $null
$global:firstLaunch = $true
$global:openSessions = Get-PSSession

function Connect-ExchangeOnline
{
  $LiveCred = $global:domainCred
  $global:Session365 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection

  Import-PSSession $global:Session365
}

function Connect-SecurityAndCompliance
{
  $LiveCred = $global:domainCred
  $global:Sec365 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $LiveCred -Authentication Basic -AllowRedirection

  Import-PSSession $global:Sec365
}

function Disconnect-ExchangeOnline
{
  Remove-PSSession $global:Session365
}

function prompt {
  $global:openSessions = Get-PSSession

  if ($global:firstLaunch -eq $true) {
    $global:firstLaunch = $false
    Clear-Host


    if ($global:domainCred -eq $null) {
      $global:domainCred = (Get-Credential -Message "Please enter domain credentials for AD and domain operations:")
    }

    Write-Host "[POSH Running As $env:Username on $env:COMPUTERNAME]"
  }

  if ($global:openSessions -ne $null) {
    Write-Host
    Write-Host "    Open Remote Sessions - Remove with Remove-PSSession   "
    forEach ($s in $global:openSessions) {
      Write-Host $s.id $s.ComputerName
    }
    Write-Host
  }

  $Global:Admin=''
  $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
  if ($principal.IsInRole("Administrators")) {
    Write-Host "[" -NoNewline -ForegroundColor Gray
    Write-Host "Admin" -NoNewline -ForegroundColor Red
    Write-Host "] " -NoNewline -ForegroundColor Gray
  }

  Write-Host "[" -NoNewline -ForegroundColor Gray
  Write-Host "$env:USERNAME@$env:COMPUTERNAME" -NoNewline -ForegroundColor Cyan
  Write-Host "] " -NoNewline -ForegroundColor Gray

  forEach ($s in $(Get-Location).ToString().ToCharArray()) {
    if ($s -eq "\") {
      Write-Host $s -NoNewline -ForegroundColor Yellow
    }else{
      Write-Host $s -NoNewline -ForegroundColor Gray
    }

  }
  Write-Host
  Write-Host " >" -NoNewline -ForegroundColor Magenta
  return " "
}

function ssh ($computername) {
  if (Test-Connection -ComputerName $computername) {
    $sess = New-PSSession -ComputerName $computername -Credential $global:domainCred
    Enter-PSSession $sess
    Get-PSSession
  }
}
