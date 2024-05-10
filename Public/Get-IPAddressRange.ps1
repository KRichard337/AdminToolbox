function Get-IPAddressRange {
    <#
.SYNOPSIS
    Generates a list of IP addresses within a specified range or CIDR.

.DESCRIPTION
    This function generates a list of IP addresses within a specified range or CIDR. It takes either a start and end IP address or a start IP address and the number of IPs to generate.

.PARAMETER StartIP
    The starting IP address of the range.

.PARAMETER EndIP
    The ending IP address of the range.

.PARAMETER NumberOfIPs
    The number of IP addresses to generate from the StartIP.

.PARAMETER CIDR
    The CIDR notation to specify the range.

.EXAMPLE
    Get-IPAddressRange -StartIP 192.168.0.1 -EndIP 192.168.0.5
    Generates a list of IP addresses from 192.168.0.1 to 192.168.0.5.

.EXAMPLE
    Get-IPAddressRange -StartIP 192.168.0.1 -NumberOfIPs 5
    Generates a list of 5 sequential IP addresses starting from 192.168.0.1.

.EXAMPLE
    Get-IPAddressRange -StartIP 192.168.0.0 -CIDR 24
    Generates a list of IP addresses within the CIDR range 192.168.0.0/24.

.NOTES
    Inspired from: https://stackoverflow.com/questions/24457902/powershell-byte-array-to-int/24463023#24463023
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ipaddress]$StartIP,

        [Parameter(Mandatory,
        ParameterSetName = 'EndIP')]
        [ipaddress]$EndIP,

        [Parameter(Mandatory,
        ParameterSetName = 'NumIPs')]
        [int]$NumberOfIPs,

        [Parameter(Mandatory,
        ParameterSetName = 'CIDR')]
        [int]$CIDR
        
    )

    $startIPArray = $StartIP.GetAddressBytes()
    [array]::Reverse($startIPArray)
    $start=[bitconverter]::ToUInt32([byte[]]$startIPArray,0)

    [System.Collections.ArrayList]$ipList = @()

    if ($EndIP){
        $endIPArray = $EndIP.GetAddressBytes()
        [array]::Reverse($endIPArray)
        $end=[bitconverter]::ToUInt32([byte[]]$endIPArray,0)
        $ipCount = $end - $start
    }
    
    if ($NumberOfIPs){
        $ipcount = $NumberOfIPs - 1
    }
    
    if ($CIDR){
        $ipCount = [math]::pow(2,32-$CIDR) - 1
    }

    for ($i = 0; $i -le $ipCount; $i++){
        $get_ip = [BitConverter]::GetBytes($start)
        [array]::Reverse($get_ip)
        [ipaddress]$new_ip = $get_ip
        $null = $ipList.Add($new_ip.IPAddressToString)
        $start++
    }
    Write-Output $ipList
}