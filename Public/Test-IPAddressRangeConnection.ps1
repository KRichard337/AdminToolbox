function Test-IPAddressRangeConnection {
<#
.SYNOPSIS
    Tests the connection to a range of IP addresses using ping.

.DESCRIPTION
    This function tests the connection to a range of IP addresses using ping. It accepts an array of IP addresses as input and sends asynchronous ping requests to each IP address. It then waits for all ping requests to complete and returns a list of IP addresses that responded successfully.

.PARAMETER IP
    Specifies an array of IP addresses to test for connectivity.

.INPUTS
    System.Net.IPAddress[]

.OUTPUTS
    System.Collections.ArrayList

.EXAMPLE
    $ipList = Get-IPAddressRange -StartIP 10.250.0.1 -EndIP 10.250.0.255 | Test-IPAddressRangeConnection
    Tests the connection to a range of IP addresses from 10.250.0.1 to 10.250.0.255 and returns a list of IP addresses that responded successfully.

.NOTES
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
        ValueFromPipeline)]
        [ipaddress[]]$IP
    )

    $Results = $IP | Foreach-Object {
        [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_)
    }
    [Threading.Tasks.Task]::WaitAll($Results)

    [System.Collections.ArrayList]$ipList = @()

    foreach ($item in $Results.result){
        if ($item.status -eq 'Success'){
            $null = $ipList.Add($item.Address.IPAddressToString)
        }
    }
    Write-Output $ipList
}