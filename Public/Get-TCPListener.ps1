function Get-TCPListenersByPort {
    <#
.SYNOPSIS
Retrieves TCP listeners on a specific port.

.DESCRIPTION
The Get-TCPListenersByPort function retrieves active TCP listeners on the specified port. It queries the system's IP global properties to get active TCP listeners and filters the list based on the specified port number.

.PARAMETER Port
Specifies the port number for which to retrieve TCP listeners.

.EXAMPLE
Get-TCPListenersByPort -Port 80
Retrieves active TCP listeners on port 80.

.NOTES
This function uses .NET methods from the System.Net.NetworkInformation namespace to retrieve active TCP listeners. It returns an array of TCP listener objects that match the specified port number.
#>

    param(
        [Parameter(Mandatory = $true)]
        [int]$Port
    )

    $listeners = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()
    $listenersOnPort = $listeners | Where-Object { $_.Port -eq $Port }
    
    return $listenersOnPort
}