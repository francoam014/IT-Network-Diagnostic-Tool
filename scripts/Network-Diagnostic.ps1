# IT Network Diagnostic Tool
# Run in PowerShell 5.1 or newer. No administrator rights required.
[CmdletBinding()]
param(
    [string]$Target = '1.1.1.1',
    [string]$DnsName = 'example.com',
    [string]$ReportPath
)
$ErrorActionPreference = 'Stop'
function Get-NetworkDiagnostic {
    param([string]$PingTarget, [string]$LookupName)
    $adapters = @(Get-NetIPConfiguration | Where-Object { $_.IPv4Address })
    $interfaces = foreach ($adapter in $adapters) {
        [pscustomobject]@{
            Name = $adapter.InterfaceAlias
            IPv4 = @($adapter.IPv4Address | ForEach-Object { $_.IPAddress }) -join ', '
            Gateway = @($adapter.IPv4DefaultGateway | ForEach-Object { $_.NextHop }) -join ', '
            DnsServers = @($adapter.DNSServer.ServerAddresses) -join ', '
        }
    }
    $pingOk = $false
    $dnsOk = $false
    $dnsAddresses = @()
    $pingError = $null
    $dnsError = $null
    try { $pingOk = [bool](Test-Connection -ComputerName $PingTarget -Count 2 -Quiet -ErrorAction Stop) }
    catch { $pingError = $_.Exception.Message }
    try {
        $dnsAddresses = @(Resolve-DnsName -Name $LookupName -Type A -ErrorAction Stop |
            Where-Object { $_.IPAddress } | Select-Object -ExpandProperty IPAddress -Unique)
        $dnsOk = $dnsAddresses.Count -gt 0
    } catch { $dnsError = $_.Exception.Message }
    [pscustomobject]@{
        Timestamp = (Get-Date).ToString('o')
        ComputerName = $env:COMPUTERNAME
        Interfaces = @($interfaces)
        PingTarget = $PingTarget
        PingSuccessful = $pingOk
        PingError = $pingError
        DnsName = $LookupName
        DnsSuccessful = $dnsOk
        DnsAddresses = @($dnsAddresses)
        DnsError = $dnsError
    }
}
try {
    $result = Get-NetworkDiagnostic -PingTarget $Target -LookupName $DnsName
    $result | Format-List Timestamp, ComputerName, PingTarget, PingSuccessful, DnsName, DnsSuccessful
    $result.Interfaces | Format-Table -AutoSize
    if ($result.DnsAddresses.Count) { Write-Host "DNS addresses: $($result.DnsAddresses -join ', ')" }
    if ($ReportPath) {
        $fullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ReportPath)
        $result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $fullPath -Encoding UTF8
        Write-Host "Report saved to: $fullPath"
    }
} catch {
    Write-Error "Diagnostic failed: $($_.Exception.Message)"
    exit 1
}
