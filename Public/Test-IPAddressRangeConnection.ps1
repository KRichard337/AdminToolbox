function Test-IPAddressRangeConnection {
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