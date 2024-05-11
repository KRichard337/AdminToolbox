function Stop-TCPListener {
    <#
.SYNOPSIS
Stops a TCP listener.

.DESCRIPTION
The Stop-TCPListener function stops a TCP listener. It stops the specified TCP listener object and disposes of the underlying socket used for listening to incoming connections.

.PARAMETER Listener
Specifies the TCP listener object to stop.

.EXAMPLE
$listener = Start-TCPListener -Port 8080
Stop-TCPListener -Listener $listener
Stops the TCP listener created with Start-TCPListener.

.NOTES
This function stops the TCP listener specified by the Listener parameter and releases any associated resources. It is recommended to call this function when the TCP listener is no longer needed to ensure proper cleanup.
#>

    param(
        [Parameter(Mandatory = $true)]
        [System.Net.Sockets.TcpListener]$Listener
    )

    process {
        $Listener.Stop()
        $Listener.Server.Dispose()
    }
}