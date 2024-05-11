function Add-PTRRecord {
<#
.SYNOPSIS
Adds a PTR record for a computer if it is missing.

.DESCRIPTION
The Add-PTRRecord function adds a PTR record for the specified computer if it does not already exist in the DNS server. It resolves the computer's DNS name and IP address, checks if a PTR record already exists for the IP address, and adds a new PTR record if one does not exist. This function is useful for maintaining reverse DNS lookup zones.

.PARAMETER ComputerName
Specifies an array of fully qualified domain names (FQDNs) of the computers for which PTR records should be added.

.PARAMETER DNSServer
Specifies the DNS server to query for DNS records. If not specified, the default DNS server configured on the local machine is used.

.EXAMPLE
Add-PTRRecord -ComputerName "example.com" -DNSServer "dns.example.com"
Adds a PTR record for the computer "example.com" using the DNS server "dns.example.com".

.NOTES
This function relies on the Resolve-DnsName cmdlet to resolve DNS records and the Add-DnsServerResourceRecordPtr cmdlet to add PTR records to the DNS server. It is designed to work with IPv4 addresses.
#>

    [CmdletBinding()]
    param(
        [Parameter (Mandatory,
            ValueFromPipeline)]
        [string[]]$ComputerName,

        [string]$DNSServer
    )
    BEGIN {
        if (-not $DNSServer){
        $DNSServer = (Get-DNSCLientServerAddress -AddressFamily IPv4 -InterfaceAlias Ethernet0 | Select-Object -ExpandProperty Serveraddresses)[0]
        }
    }

    PROCESS {
        foreach ($Computer in $ComputerName) {
            $DNSRecord = Resolve-DnsName $computer
            $hostname = $DNSRecord.name
            $IP = $DNSRecord.IPAddress

            $PTRCheck = Resolve-DnsName $IP -QuickTimeout -ErrorAction SilentlyContinue

            if ($null -eq $PTRCheck) {
                $Zones = Get-DNSServerZone -ComputerName $DNSServer | Where-Object { $_.isreverselookupzone -eq $true } | Select-Object -ExpandProperty ZoneName
                $IParray = New-Object System.Collections.ArrayList
                $IP.split('.') | Foreach-Object { $IPArray.Add($_) } | Out-Null
                $IParray.reverse()
                $PTRIP = New-Object System.Collections.ArrayList
                Do {
                    $octet = $iparray[0]
                    $IParray.remove($IPArray[0])
                    if ($IPArray.count -lt 1){
                        throw "Cannot find a PTR Zone"
                        continue
                    }
                    $null = $PTRIP.Add($octet)
                    $PTRName = ($IParray -join ".") + ".in-addr.arpa"
                    $PTRZone = ($Zones -match "^$PTRName$")[0]
                    $NameIP = ($PTRIP -join ".")
                }
                until ($PTRZone)
                try {
                    Add-DnsServerResourceRecordPtr -Name $NameIP -ZoneName $PTRZone -ComputerName $DNSServer -PtrDomainName $hostname -ErrorAction Stop
                    $Result = 'Success'
                }
                catch {
                    $Result = 'Failed'
                }
            }
            else {
                $Result = 'Skipped'
            }
            $OutputObj = [pscustomobject] @{
                Computername = $Computer
                IP = $IP
                Result = $Result
            }
            Write-Output $OutputObj
        }
    }
    END {}
}