# IT Network Diagnostic Tool

A beginner-friendly **PowerShell network diagnostic utility** for Windows IT support and network troubleshooting.

## Features
- Lists active IPv4 interfaces, default gateways and DNS servers.
- Tests ICMP connectivity to a configurable target.
- Resolves a configurable DNS hostname.
- Optionally exports a diagnostic result to JSON.
- Handles connection and DNS failures without crashing.

## Requirements
Windows 10/11 or Windows Server with Windows PowerShell 5.1 or newer. No administrator rights are required for normal use.

## Quick start
Download or clone the repository, open PowerShell in its folder, and run:

```powershell
.\scripts\Network-Diagnostic.ps1
```

Use custom targets and save a JSON report:

```powershell
.\scripts\Network-Diagnostic.ps1 -Target 8.8.8.8 -DnsName github.com -ReportPath .\diagnostic-report.json
```

If Windows blocks the script, check your organization's execution policy; do not disable security controls globally.

## Example output
```text
ComputerName    : DESKTOP-EXAMPLE
PingTarget      : 1.1.1.1
PingSuccessful  : True
DnsName         : example.com
DnsSuccessful   : True

Name       IPv4          Gateway       DnsServers
----       ----          -------       ----------
Wi-Fi      192.168.1.20  192.168.1.1   192.168.1.1
```

*Illustrative example, not a real diagnostic result.*

## Notes
- Ping can fail even when internet works, because some networks block ICMP.
- Successful DNS resolution does not guarantee website availability.
- Reports may contain local network information: review before sharing.
- The script runs locally and does not upload reports.

## Roadmap
- [ ] HTTP connectivity testing
- [ ] Optional route tracing
- [ ] Pester tests with mocked network commands
- [ ] CSV export

## License
MIT — see [LICENSE](LICENSE).
