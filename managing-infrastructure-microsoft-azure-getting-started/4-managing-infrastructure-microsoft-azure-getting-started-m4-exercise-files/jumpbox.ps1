### JUMPBOX ###

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

Install-Module -Name AzureRM -Verbose -Force

Update-Help -Force -ErrorAction SilentlyContinue

Get-Item -Path WSMan:\localhost\Client\TrustedHosts

Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value *

$cred1 = Get-Credential -UserName 'tim' -Message 'Enter VM admin credentials'
$web1 = New-PSSession -ComputerName 1.2.3.4 -Credential $cred1 -Name 'web1'

$web1 | Enter-PSSession

Exit-PSSession

Get-Command -Noun PSSession

Get-Help -Name Remove-PSSession -ShowWindow

Get-Help -Name about_Remote_Disconnected_Sessions -ShowWindow
