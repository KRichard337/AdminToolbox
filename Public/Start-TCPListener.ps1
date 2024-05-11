function Start-TCPListener {
    <#
.SYNOPSIS
Starts a TCP listener on the specified port.

.DESCRIPTION
The Start-TCPListener function starts a TCP listener on the specified port. It creates a new TCP listener object and starts listening for incoming connections on the specified port.

.PARAMETER Port
Specifies the port number on which to start the TCP listener.

.EXAMPLE
Start-TCPListener -Port 8080
Starts a TCP listener on port 8080.

.NOTES
This function uses the System.Net.Sockets.TcpListener class to create and manage the TCP listener. It does not handle incoming connections or perform any additional processing beyond starting the listener.
#>

    param(
        [Parameter(Mandatory = $true)]
        [int]$Port
    )
    Begin {}

    Process {
        $listener = [System.Net.Sockets.TcpListener]$Port

        $listener.Start()

        $listener

    }
}